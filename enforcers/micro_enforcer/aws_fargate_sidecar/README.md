# Inject microenforcer as a sidecar to AWS ECS Task Definition

## Overview

`inject_microenforcer.py` is a Python script that automates the integration of Aqua MicroEnforcer into an AWS ECS task definition. This enhances container security by injecting the Aqua security agent and its required configurations into existing task definitions.

## Features

 - Parses AWS ECS task definition JSON files.
 - Adds Aqua MicroEnforcer as a sidecar container.
 - Updates container definitions with necessary environment variables and volume mounts.
 - Configures entry points and commands for each container.
 - Optionally updates the task execution role ARN.
 - Supports input and output of task definitions in JSON format.
 - Supports MicroEnforcers stored in Amazon Elastic Container Registry (ECR).

## Requirements

If using a local setup instead of AWS CloudShell, ensure the following:
- **Python**: Version 3.7 or higher.
- **Docker**: Local Docker installation to pull and inspect container images.
- **Python Libraries**:
  - `argparse`
  - `json`
  - `docker` (`pip install docker`)

## Usage

1. Download the ECS Task Definition
	1.	Go to AWS ECS → Task Definitions.
	2.	Select the task definition and revision you want to modify.
	3.	Click the JSON tab and download the AWS CLI Input file.
 
2. Upload Files to AWS CloudShell
	1.	Open AWS CloudShell.
	2.	Upload the MicroEnforcer Injection Script:
	    - [Download Script](https://github.com/aquasecurity/deployments/tree/2022.4/enforcers/micro_enforcer/aws_fargate_sidecar)
        - Use Actions → Upload File in CloudShell.
	3.	Upload the task definition JSON file.
3. Run the Script
 
Execute the script with the required arguments:

    python inject_microenforcer.py \
    -i original-task-definition-AWS-CLI-input.json \
    -u <AQUA_GATEWAY_URL> \
    -t <AQUA_DEPLOYMENT_TOKEN> \
    -m registry.aquasec.com/microenforcer-basic:<release-number> \
    -s <AWS_SECRETS_MANAGER_ARN> \
    -e <ECS_TASK_EXECUTION_ROLE_ARN> \
    -o updated-task-definition.json

For a more detailed step-by-step guide, visit:

📖 [Full Guide on Aqua Wiki](https://wiki-aquasec.atlassian.net/wiki/spaces/RD/pages/1331429708/Auto+Deployment+Microenforcer+Script)
### Flow
- **Download AWS ECS task definition JSON file**
  - In AWS console locate your task definition under ECS -> Task Definitions
  - Select task definition revision
  - Select "JSON" tab under "Overview" section
  - Click on "Download AWS CLI input"
  - Use the downloaded file path as an `--input-json-file` in the script below
- **Create secret for private registry**
  - Should private registry be used, like registry.aquasec.com, or any other container registry which requires username and password to pull images following instructions have to be followed:
    https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html
- **Execute script** as shown in Example command section.
- **Create new task definition revision**
  - Copy terminal output or the content of `--output-json-file` if selected
  - In AWS console locate your task definition under ECS -> Task Definitions
  - Select "Create new revision" -> "Create new revision with JSON"
  - Replace json with the content from the script output
  - Select "Create"
- **Update task or service**
  - Proceed as usual to update your task or service with the updated task definition


### Command-Line Arguments

| Argument                                | Description                                                                                                                                                                                      | Required                        |
|-----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|
| `-i`, `--input-json-file`               | Input ECS task definition JSON file.                                                                                                                                             | Yes                             |
| `-u`, `--aqua-gateway-url`              | Aqua Gateway URL and port.                                                                                                                          | Yes                             |
| `-t`, `--aqua-token`                    | MicroEnforcer deployment token.                   | Yes                             |
| `-m`, `--image`                         | Aqua MicroEnforcer image.                                                                                                          | Yes                             |
| `-s`, `--image-creds-secretmanager-arn` | AWS Secrets Manager ARN for registry credentials | Required for private registries |
| `-e`, `--task-execution-role-arn`       | ARN for the ECS task execution role.                                  | Required for private registries |
| `-o`, `--output-json-file`              | Name of the updated task definition file.                                                                                                                                          | No                              |

### Example Command

```bash
python inject_microenforcer.py \
    -i task_definition.json \
    -u aqua-gateway-url.com \
    -t your-auth-token \
    -m registry.aquasec.com/microenforcer-basic:2022.4.662 \
    -o updated_task_definition.json
```

### Expected result

Given input task definition:
```json
{
    "family": "example-task-definition",
    "containerDefinitions": [
        {
            "name": "gotty",
            "image": "dieterreuter/gotty",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "http-8080",
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [],
            "mountPoints": [],
            "volumesFrom": [],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/example-task-definition",
                    "mode": "non-blocking",
                    "awslogs-create-group": "true",
                    "max-buffer-size": "25m",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "systemControls": []
        }
    ],
    "executionRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/ecsTaskExecutionRole",
    "networkMode": "awsvpc",
    "volumes": [],
    "placementConstraints": [],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "3072",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    }
}
```

The expected result should be:
```json
{
    "family": "example-task-definition",
    "containerDefinitions": [
        {
            "name": "gotty",
            "image": "dieterreuter/gotty",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "http-8080",
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
            "environment": [
                {
                    "name": "AQUA_MICROENFORCER",
                    "value": "1"
                },
                {
                    "name": "AQUA_SERVER",
                    "value": "aqua_gateway_url:443"
                },
                {
                    "name": "AQUA_TOKEN",
                    "value": "211029312309-210391u20132-1231o23h"
                },
                {
                    "name": "LD_PRELOAD",
                    "value": "/.aquasec/bin/$PLATFORM/slklib.so"
                }
            ],
            "mountPoints": [],
            "volumesFrom": [
                {
                    "sourceContainer": "aqua-sidecar",
                    "readOnly": false
                }
            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/example-task-definition",
                    "mode": "non-blocking",
                    "awslogs-create-group": "true",
                    "max-buffer-size": "25m",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "systemControls": [],
            "entryPoint": [
                "/.aquasec/bin/microenforcer"
            ],
            "command": [
                "/gotty",
                "--permit-write",
                "--reconnect",
                "/bin/ash"
            ]
        },
        {
            "name": "aqua-sidecar",
            "image": "registry.aquasec.com/microenforcer-basic:2022.4.662",
            "cpu": 0,
            "portMappings": [],
            "essential": false,
            "environment": [],
            "environmentFiles": [],
            "mountPoints": [],
            "volumesFrom": [],
            "systemControls": [],
            "repositoryCredentials": {
                "credentialsParameter": "arn:aws:secretsmanager:AWS-REGION:AWS_ACCOUNT_ID:secret:aquasec-registry"
            }
        }
    ],
    "executionRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/updatedEcsTaskExecutionRole",
    "networkMode": "awsvpc",
    "volumes": [],
    "placementConstraints": [],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "3072",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    }
}
```

The diff between input and output will be:
```diff
{
    "family": "example-task-definition",
    "containerDefinitions": [
        {
            "name": "gotty",
            "image": "dieterreuter/gotty",
            "cpu": 0,
            "portMappings": [
                {
                    "name": "http-8080",
                    "containerPort": 8080,
                    "hostPort": 8080,
                    "protocol": "tcp",
                    "appProtocol": "http"
                }
            ],
            "essential": true,
+            "environment": [
+                {
+                    "name": "AQUA_MICROENFORCER",
+                    "value": "1"
+                },
+                {
+                    "name": "AQUA_SERVER",
+                    "value": "aqua_gateway_url:443"
+                },
+                {
+                    "name": "AQUA_TOKEN",
+                    "value": "211029312309-210391u20132-1231o23h"
+                },
+                {
+                    "name": "LD_PRELOAD",
+                    "value": "/.aquasec/bin/$PLATFORM/slklib.so"
+                }
+            ],
            "mountPoints": [],
+            "volumesFrom": [
+                {
+                    "sourceContainer": "aqua-sidecar",
+                    "readOnly": false
+                }
+            ],
            "logConfiguration": {
                "logDriver": "awslogs",
                "options": {
                    "awslogs-group": "/ecs/example-task-definition",
                    "mode": "non-blocking",
                    "awslogs-create-group": "true",
                    "max-buffer-size": "25m",
                    "awslogs-region": "us-east-1",
                    "awslogs-stream-prefix": "ecs"
                }
            },
            "systemControls": [],
+            "entryPoint": [
+                "/.aquasec/bin/microenforcer"
+            ],
+            "command": [
+                "/gotty",
+                "--permit-write",
+                "--reconnect",
+                "/bin/ash"
+            ]
        },
+        {
+            "name": "aqua-sidecar",
+            "image": "registry.aquasec.com/microenforcer-basic:2022.4.662",
+            "cpu": 0,
+            "portMappings": [],
+            "essential": false,
+            "environment": [],
+            "environmentFiles": [],
+            "mountPoints": [],
+            "volumesFrom": [],
+            "systemControls": [],
+            "repositoryCredentials": {
+                "credentialsParameter": "arn:aws:secretsmanager:AWS-REGION:AWS_ACCOUNT_ID:secret:aquasec-registry"
+            }
+        }
    ],
-    "executionRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/ecsTaskExecutionRole",
+    "executionRoleArn": "arn:aws:iam::AWS_ACCOUNT_ID:role/updatedEcsTaskExecutionRole",
    "networkMode": "awsvpc",
    "volumes": [],
    "placementConstraints": [],
    "requiresCompatibilities": [
        "FARGATE"
    ],
    "cpu": "1024",
    "memory": "3072",
    "runtimePlatform": {
        "cpuArchitecture": "X86_64",
        "operatingSystemFamily": "LINUX"
    }
}
```

## Functionality

1. **Parse Arguments**: Uses `argparse` to process command-line inputs.
2. **Read Input JSON**: Loads the input ECS task definition JSON file.
3. **Retrieve Container Image Metadata**: Pulls and inspects Docker images to extract `entryPoint` and `command` configurations.
4. **Create Aqua Sidecar Container**: Configures a new sidecar container for Aqua MicroEnforcer.
5. **Modify Task Definition**:
   - Adds environment variables (`AQUA_MICROENFORCER`, `AQUA_SERVER`, `AQUA_TOKEN`, etc.).
   - Mounts necessary volumes.
   - Adjusts entry points and commands for containers.
   - Appends the Aqua sidecar container to the task definition.
6. **Write Output JSON**: Saves the updated task definition to a file or prints it to the console.

 ## Error Handling and Notes

- The script validates input files and checks for missing dependencies.
- Docker must be running for local setups (non CloudShell setups).
- Ensure AWS IAM roles and permissions are correctly configured.

## License

This script is provided as-is, with no warranties. Users are responsible for verifying security and compatibility in their environments.


