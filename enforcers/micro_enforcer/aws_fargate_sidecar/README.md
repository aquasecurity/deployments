# README for `inject_microenforcer.py`

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

### Command-Line Arguments

| Argument                             | Description                                                                                  | Required |
|--------------------------------------|----------------------------------------------------------------------------------------------|----------|
| `-i`, `--input-json-file`            | Path to the input AWS ECS task definition JSON file.                                         | Yes      |
| `-u`, `--server-url`                 | URL of the Aqua server.                                                                      | Yes      |
| `-t`, `--token`                      | Authorization token for the MicroEnforcer group.                                             | Yes      |
| `-m`, `--image`                      | Aqua MicroEnforcer image (e.g., `registry.aquasec.com/microenforcer-basic:2022.4.662`).     | Yes      |
| `-s`, `--image-creds-secretmanager-arn` | ARN for image registry credentials stored in AWS Secrets Manager.                            | No       |
| `-e`, `--task-execution-role-arn`    | ARN for the task execution role.                                                            | No       |
| `-o`, `--output-json-file`           | Path to save the updated ECS task definition JSON file.                                      | No       |

### Example Command

```bash
python inject_microenforcer.py \
    -i task_definition.json \
    -u https://aqua-server-url.com \
    -t your-auth-token \
    -m registry.aquasec.com/microenforcer-basic:2022.4.662 \
    -o updated_task_definition.json
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