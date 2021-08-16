# Deploy VM Enforcer using Ansible

## Overview

You can deploy VM Enforcers, using an Ansible playbook, on the desired VM Enforcer group. This procedure is supported for Linux platforms only.

## Prerequisites for deploying VM Enforcers

* VM Enforcer Group token. Refer to [Create a VM Enforcer Group and VM Enforcer](https://docs.aquasec.com/docs/create-a-vm-enforcer-group-and-vm-enforcer) to create this token.
* Aqua username and password
* Following packages are required on the VM to install VM Enforcer:
   * jq
   * runc
   * tar
   * wget

## Preparation

**Step 1. Download the Ansible playbook**

```shell
git clone https://github.com/aquasecurity/deployments.git -b 6.5
cd ./deployments/enforcers/vm_enforcer/ansible/
```

**Step 2. Create a `hosts` file with the IP or DNS addresses of the VM(s).** For example:

```bash
[all]     # list the IP/DNS addresses of the VMs to deploy VM Enforcer
10.0.0.1 
10.0.0.x
test.aqua.com
```

**Step 3. Prepare the deployment yaml file to deploy VM Enforcer.** This step is required only if you want to add [mandatory variables](#mandatory-variables) in the deployment yaml file.

## Deploy VM Enforcer

Deploy VM Enforcer using one of the following procedures.

### Deployment using environment variables
1. Clone Aqua VM Enforcer Anisble repo

```shell
git clone https://github.com/aquasecurity/deployments.git
cd deployments/VM-Enforcer/ansible/
```

2. In the following command, add the [mandatory variables](#mandatory-variables) with the `--extra-vars` flag and run it.

```shell
ansible-playbook vm-enforcer.yaml -i ./path/to/hosts -e vme_install=true --extra-vars "USERNAME=<username> PASSWORD=<password> ENFORCER_VERSION=<version> TOKEN=<token> GATEWAY_ENDPOINT=<endpoint>:<port>"
```

## Mandatory variables

VM Enforcer deployment requires the following mandatory variables:

   |Variable|Description|
   | ------- | -------- |
   |USERNAME         | Username to download the VM Enforcer package <br>(`.tar` or `.rpm`, depending on the Linux distro) |
   |PASSWORD         | Password of the specified user |
   |ENFORCER_VERSION | Version of the VM Enforcer |
   |TOKEN            | Token of the Enforcer group |
   |GATEWAY_ENDPOINT | Gateway endpoint <br>Format: `<IP/Hostname>:<Port>` |

## Remove the VM Enforcer(s)

Run the following command to remove the VM Enforcer from your VM:

```shell
ansible-playbook vm-enforcer.yaml -i ./path/to/hosts -e vme_uninstall=true
```