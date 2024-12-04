import argparse
import json
import docker


def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Inject micorenforcer to AWS task definition JSON."
    )
    parser.add_argument("-i", "--input-json-file", type=str, help="Path to the input AWS ECS task definition JSON file.", required=True)
    parser.add_argument("-u", "--aqua-gateway-url", type=str, help="IP address and port of any Aqua Gateway, as received from Aqua Security.", required=True)
    parser.add_argument("-t", "--aqua-token", type=str, help="Deployment token of any MicroEnforcer group. In the Aqua UI: Navigate to Administration > Enforcers and edit a MicroEnforcer group (e.g., the 'default micro enforcer group').",
                        required=True)
    parser.add_argument("-m", "--image", type=str,
                        help="Aqua MicroEnforcer image (e.g., `registry.aquasec.com/microenforcer-basic:2022.4.662`).",
                        required=True)
    parser.add_argument("-s", "--image-creds-secretmanager-arn", type=str,
                        help="ARN for image registry credentials stored in AWS Secrets Manager.", required=False)
    parser.add_argument("-e", "--task-execution-role-arn", type=str, help="ARN for the task execution role.", required=False)
    parser.add_argument("-o", "--output-json-file", type=str, help="Path to save the updated ECS task definition JSON file.", required=False)
    return parser.parse_args()


def read_json(json_file_path):
    try:
        with open(json_file_path, 'r') as file:
            return json.load(file)
    except Exception as e:
        print(f"ERROR: Error reading JSON file: {e}")
        return None


def get_entry_point_from_image(image_name: str()) -> list():
    entry_point = list()
    client = docker.from_env()
    try:
        image = client.images.get(image_name)
    except docker.errors.ImageNotFound as e:
        client.images.pull(image_name)
        image = client.images.get(image_name)

    if image and image.attrs['Config']['Entrypoint']:
        entry_point = image.attrs['Config']['Entrypoint']
    return entry_point


def get_command_from_image(image_name: str()) -> list():
    command = list()
    client = docker.from_env()
    try:
        image = client.images.get(image_name)
    except docker.errors.ImageNotFound as e:
        client.images.pull(image_name)
        image = client.images.get(image_name)

    if image and image.attrs['Config']['Cmd']:
        command = image.attrs['Config']['Cmd']
    return command


def create_aqua_sidecar_container(image: str(), credentials: str()) -> dict():
    # Add aqua-sidecar container
    aqua_sidecar = dict({
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
    })
    if credentials:
        repository_credentials = {
            'credentialsParameter': credentials
        }
        aqua_sidecar['repositoryCredentials'] = repository_credentials
    return aqua_sidecar


def inject_microenforcer_to_ecs_task_definition(aqua_sidecar: dict(), task_definition: str(),
                                                aqua_server_url: str(), aqua_token: str(),
                                                execution_role=None) -> str():
    # For each container in container definition
    for container in task_definition['containerDefinitions']:
        # Set environment variables
        container['environment'].append({'name': 'AQUA_MICROENFORCER', 'value': '1'})
        container['environment'].append({'name': 'AQUA_SERVER', 'value': aqua_server_url})
        container['environment'].append({'name': 'AQUA_TOKEN', 'value': aqua_token})
        container['environment'].append({'name': 'LD_PRELOAD', 'value': '/.aquasec/bin/$PLATFORM/slklib.so'})
        # Mount volumes
        container['volumesFrom'].append({'sourceContainer': 'aqua-sidecar', 'readOnly': False})
        # Replace entrypoint
        if 'entryPoint' not in container:
            # try to get entryPoint from docker inspect
            container['entryPoint'] = get_entry_point_from_image(container['image'])
        container['entryPoint'].insert(0, '/.aquasec/bin/microenforcer')
        if 'command' not in container:
            container['command'] = get_command_from_image(container['image'])

    # Attach aqua-sidecar container
    task_definition['containerDefinitions'].append(aqua_sidecar)

    # Update task execution role
    if execution_role:
        task_definition['executionRoleArn'] = execution_role

    return task_definition


def main():
    args = parse_arguments()

    # Read JSON file
    task_definition = read_json(args.input_json_file)
    if not task_definition:
        return

    aqua_sidecar = create_aqua_sidecar_container(image=args.image, credentials=args.image_creds_secretmanager_arn)
    secured_ecs_task_definition = inject_microenforcer_to_ecs_task_definition(aqua_sidecar=aqua_sidecar,
                                                                              task_definition=task_definition,
                                                                              aqua_server_url=args.aqua_gateway_url,
                                                                              aqua_token=args.aqua_token,
                                                                              execution_role=args.task_execution_role_arn)
    if not secured_ecs_task_definition:
        print("ERROR: Failed to inject microenforcer to the tas definition")
        return
    if args.output_json_file:
        # write to file
        with open(args.output_json_file, "w") as outfile:
            outfile.write(json.dumps(secured_ecs_task_definition, indent=4))

    print(json.dumps(secured_ecs_task_definition, indent=4))


if __name__ == '__main__':
    main()
