import argparse
import json
import docker
import re
import boto3
import base64
from typing import Tuple, List, Dict, Optional

def parse_arguments() -> argparse.Namespace:
    """Parse command-line arguments."""
    parser = argparse.ArgumentParser(
        description="Inject MicroEnforcer to AWS ECS task definition JSON."
    )
    parser.add_argument("-i", "--input-json-file", type=str, required=True,
                        help="Path to the input AWS ECS task definition JSON file.")
    parser.add_argument("-u", "--aqua-gateway-url", type=str, required=True,
                        help="IP address and port of any Aqua Gateway.")
    parser.add_argument("-t", "--aqua-token", type=str, required=True,
                        help="Deployment token for the MicroEnforcer group.")
    parser.add_argument("-m", "--image", type=str, required=True,
                        help="Aqua MicroEnforcer image (e.g., registry.aquasec.com/microenforcer:latest).")
    parser.add_argument("-s", "--image-creds-secretmanager-arn", type=str,
                        help="ARN for image registry credentials stored in AWS Secrets Manager.")
    parser.add_argument("-e", "--task-execution-role-arn", type=str,
                        help="ARN for the task execution role.")
    parser.add_argument("-o", "--output-json-file", type=str,
                        help="Path to save the updated ECS task definition JSON file.")
    return parser.parse_args()

def read_json(json_file_path: str) -> Optional[Dict]:
    """Read JSON data from a file."""
    try:
        with open(json_file_path, 'r') as file:
            return json.load(file)
    except (IOError, json.JSONDecodeError) as e:
        print(f"ERROR: Error reading JSON file: {e}")
        return None

def parse_ecr_image(image_name: str) -> Tuple[bool, Optional[str], Optional[str], Optional[str], Optional[str]]:
    """Extract AWS account ID, region, and repository from an ECR image name."""
    pattern = r"^(\d{12})\.dkr\.ecr\.([a-z0-9-]+)\.amazonaws\.com/([^:]+):([^:]+)$"
    match = re.match(pattern, image_name)

    if match:
        return True, *match.groups()
    return False, None, None, None, None

def get_ecr_login(region: str) -> Tuple[str, str, str]:
    """Retrieve ECR authentication credentials using boto3."""
    ecr_client = boto3.client("ecr", region_name=region)
    response = ecr_client.get_authorization_token()

    auth_data = response["authorizationData"][0]
    token = auth_data["authorizationToken"]
    registry_url = auth_data["proxyEndpoint"]

    username, password = base64.b64decode(token).decode().split(":")
    return registry_url, username, password

def docker_login(client: docker.DockerClient, registry_url: str, username: str, password: str) -> None:
    """Log in to Docker using credentials."""
    client.login(username=username, password=password, registry=registry_url)

def get_image_properties(image_name: str, property_key: str) -> List[str]:
    """Retrieve specific image properties (entrypoint or command) from a Docker image."""
    client = docker.from_env()
    is_valid, _, region, _, _ = parse_ecr_image(image_name)

    if is_valid:
        registry_url, username, password = get_ecr_login(region)
        docker_login(client, registry_url, username, password)

    try:
        image = client.images.get(image_name)
    except docker.errors.ImageNotFound:
        image = client.images.pull(image_name)

    return image.attrs['Config'].get(property_key, [])

def create_aqua_sidecar_container(image: str, credentials: Optional[str]) -> Dict:
    """Create the Aqua sidecar container definition."""
    aqua_sidecar = {
        'name': 'aqua-sidecar',
        'image': image,
        'cpu': 0,
        'portMappings': [],
        'essential': False,
        'environment': [],
        'environmentFiles': [],
        'mountPoints': [],
        'volumesFrom': [],
        'systemControls': []
    }

    if credentials:
        aqua_sidecar['repositoryCredentials'] = {'credentialsParameter': credentials}

    return aqua_sidecar

def inject_microenforcer(task_definition: Dict, aqua_sidecar: Dict, aqua_server_url: str,
                         aqua_token: str, execution_role: Optional[str] = None) -> Dict:
    """Inject the MicroEnforcer into the ECS task definition."""
    for container in task_definition['containerDefinitions']:
        container['environment'].extend([
            {'name': 'AQUA_MICROENFORCER', 'value': '1'},
            {'name': 'AQUA_SERVER', 'value': aqua_server_url},
            {'name': 'AQUA_TOKEN', 'value': aqua_token},
            {'name': 'LD_PRELOAD', 'value': '/.aquasec/bin/$PLATFORM/slklib.so'}
        ])

        container['volumesFrom'].append({'sourceContainer': 'aqua-sidecar', 'readOnly': False})

        if 'entryPoint' not in container or container['entryPoint'] is None:
            container['entryPoint'] = get_image_properties(container['image'], 'Entrypoint') or []
        container['entryPoint'].insert(0, '/.aquasec/bin/microenforcer')

        if 'command' not in container or container['command'] is None:
            container['command'] = get_image_properties(container['image'], 'Cmd') or []

    task_definition['containerDefinitions'].append(aqua_sidecar)

    if execution_role:
        task_definition['executionRoleArn'] = execution_role

    return task_definition

def main() -> None:
    args = parse_arguments()

    task_definition = read_json(args.input_json_file)
    if not task_definition:
        return

    aqua_sidecar = create_aqua_sidecar_container(args.image, args.image_creds_secretmanager_arn)

    updated_task_definition = inject_microenforcer(task_definition, aqua_sidecar,
                                                   args.aqua_gateway_url, args.aqua_token,
                                                   args.task_execution_role_arn)

    output_path = args.output_json_file or 'updated_task_definition.json'
    with open(output_path, "w") as outfile:
        json.dump(updated_task_definition, outfile, indent=4)

    print(json.dumps(updated_task_definition, indent=4))

if __name__ == '__main__':
    main()
