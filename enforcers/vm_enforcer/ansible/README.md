# Deploy VM Enforcer using Ansibel Playbook

## Overview

You can deploy VM Enforcers, using an Ansible playbook, on the desired VM Enforcer group. This procedure is supported for Linux platforms only.

## Prerequisites for deploying VM Enforcers

* VM Enforcer Group token. Refer to [Create a VM Enforcer Group and VM Enforcer](https://docs.aquasec.com/v6.5/docs/create-a-vm-enforcer-group-and-vm-enforcer) to create this token.
* Aqua username and password
* Following packages are required on the VM to install VM Enforcer:
   * runc
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
10.0.0.1       ansible_ssh_private_key_file=~/.ssh/test-key    ansible_user=test-user
10.0.0.x       ansible_ssh_private_key_file=~/.ssh/test-key
test.aqua.com  ansible_user=test-user
```

## Deploy VM Enforcer on all VMs using ansible-playbook

Add the [mandatory\optional variables](#mandatory-variables) with the `--extra-vars` flag in the deployment command as shown below, and run the command.


Mandatory:
 * USERNAME
 * PASSWORD
 * ENFORCER_VERSION
 * TOKEN
 * GATEWAY_ENDPOINT

Optional (**MANDATORY** for aqua **cloud** users with value `true`)
 * AQUA_TLS_VERIFY_VALUE

```shell
ansible-playbook vm-enforcer.yaml -i ./path/to/hosts -e vme_install=true --extra-vars "USERNAME=<username> PASSWORD=<password> ENFORCER_VERSION=<version> TOKEN=<token> GATEWAY_ENDPOINT=<endpoint>:<port>
AQUA_TLS_VERIFY=<AQUA_TLS_VERIFY_VALUE>"
 
```
##  Uninstall VM Enforcer from all VMs using ansible-playbook

```shell
ansible-playbook vm-enforcer.yaml -i ./path/to/hosts -e vme_uninstall=true
```

## References
* Getting started with [Ansible](https://docs.ansible.com/ansible/latest/user_guide/intro_getting_started.html) and [Run your first Playbook](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html) guides.
* [Aqua VM Enforcer Overview](../README.md) and all other [Aqua Enforcers types](../../README.md) overview
* Aqua VM Enforcers [official documentation](https://docs.aquasec.com/v6.5/docs/vm-enforcer)
