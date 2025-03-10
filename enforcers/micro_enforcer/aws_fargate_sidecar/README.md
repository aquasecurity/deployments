# Inject microenforcer as a sidecar to AWS ECS Task Definition

## Overview

`inject_microenforcer.py` is a Python script designed to integrate Aqua MicroEnforcer into an AWS ECS task definition. This process enhances container security by injecting the Aqua security agent and its configurations into existing task definitions.

## Features

- Parses AWS ECS task definition JSON files.
- Adds Aqua MicroEnforcer as a sidecar container.
- Updates container definitions with necessary environment variables and volume mounts.
- Configures entry points and commands for each container.
- Optionally updates the task execution role ARN.
- Supports input and output of task definitions in JSON format.

## Requirements

- **Python**: Version 3.7 or higher.
- **Docker**: Local Docker installation to pull and inspect container images.
- **Python Libraries**:
  - `argparse`
  - `json`
  - `docker` (`pip install docker`)

## Usage

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
| `-i`, `--input-json-file`               | Path to the input AWS ECS task definition JSON file.                                                                                                                                             | Yes                             |
| `-u`, `--aqua-gateway-url`              | IP address and port of any Aqua Gateway, as received from Aqua Security                                                                                                                          | Yes                             |
| `-t`, `--aqua-token`                    | Deployment token of any MicroEnforcer group. In the Aqua UI: Navigate to Administration > Enforcers and edit a MicroEnforcer group (e.g., the "default micro enforcer group").                   | Yes                             |
| `-m`, `--image`                         | Aqua MicroEnforcer image (e.g., `registry.aquasec.com/microenforcer-basic:2022.4.662`).                                                                                                          | Yes                             |
| `-s`, `--image-creds-secretmanager-arn` | ARN for image registry credentials stored in AWS Secrets Manager. ( To create required resources please refer to https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html ) | Required for private registries |
| `-e`, `--task-execution-role-arn`       | ARN for the task execution role. ( To create required resources please refer to https://docs.aws.amazon.com/AmazonECS/latest/developerguide/private-auth.html )                                  | Required for private registries |
| `-o`, `--output-json-file`              | Path to save the updated ECS task definition JSON file.                                                                                                                                          | No                              |

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

## Error Handling

- Reports errors in reading input files.
- Ensures the specified Docker image exists or pulls it from the registry.
- Prints error messages for issues in modifying the task definition.

## Notes

- Docker must be running on the system where this script is executed.
- Ensure AWS IAM roles and permissions are properly configured to use the provided ARNs.

## License

This script is provided as-is, without any warranties. Users are responsible for ensuring its compatibility and security in their environments.
