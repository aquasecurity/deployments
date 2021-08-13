# Deploy VM Enforcer using RPM

## Overview
The RPM Package Manager (RPM) is a powerful package management system used by Red Hat Linux and its derivatives such as CentOS and Fedora. RPM also refers to the `rpm` command and `.rpm` file format. 

You can use RPM to deploy a VM Enforcer on one or more VMs (hosts).
## Prerequisites

* VM Enforcer Group token. Refer [Create a VM Enforcer Group and VM Enforcer](https://docs.aquasec.com/docs/create-a-vm-enforcer-group-and-vm-enforcer) to create this token.
* Aqua username and password
* Following packages are required for installing VM Enforcer `.rpm` package
  * wget
  * tar
  * jq
  * runc

## Deploy VM Enforcer

**Step 1. Download the RPM package from Aqua Security by using an authorized username and password.**

* For x86_64/amd64 systems:

    ```shell
    wget -v https://download.aquasec.com/host-enforcer/6.2.0/aqua-vm-enforcer-6.2.21166.x86_64.rpm --user=<Username> --ask-password
    ```

* For arm64 systems:

    ```shell
    wget -v https://download.aquasec.com/host-enforcer/6.2.0/aqua-vm-enforcer-6.2.21166.aarch64.rpm --user=<Username> --ask-password
    ```

**Step 2. Copy the downloaded RPM package to the VM(s) on which you want to deploy a VM Enforcer.**

**Step 3. Create the `aquavmenforcer.json` configuration file.** This is to configure the Gateway address and Enforcer group token.

```shell
sudo mkdir -p /etc/conf/ && sudo touch /etc/conf/aquavmenforcer.json
```

**Step 4. Execute the following command.** Enter values for the following parameters in the command:
 - `<GATEWAY_HOSTENAME>:<PORT>`: Aqua Gateway host/IP address and port
 - `<TOKEN VALUE>`: Enforcer group token

```shell
sudo tee /etc/conf/aquavmenforcer.json << EOF
{
    "AQUA_GATEWAY": "{GATEWAY_HOSTENAME}:{PORT}",
    "AQUA_TOKEN": "{TOKEN VALUE}"
}
EOF
```

**Step 5. Deploy the RPM.**

```shell
sudo rpm -ivh /path/to/aqua-vm-enforcer-{version}.{arch}.rpm
```

## Upgrade VM Enforcer

**Step 1. Download the (updated) RPM package from Aqua Security, by using an authorized username and password.**

* For x86_64/amd64 systems:

    ```shell
    wget -v https://download.aquasec.com/internal/host-enforcer/6.2.0/aqua-vm-enforcer-{version}.x86_64.rpm --user=<Username> --ask-password
    ```

* For arm64 systems:
  
    ```shell
    wget -v https://download.aquasec.com/internal/host-enforcer/6.2.0/aqua-vm-enforcer-{version}.aarch64.rpm --user=<Username> --ask-password
    ```

    `version`: Enter latest vm-enforcer version

**Step 2. Upgrade VM Enforcer**

```shell
    sudo rpm -U /path/to/aqua-vm-enforcer-{version}.{arch}.rpm
```

## Check the VM Enforcer application logs

Execute the following command to check the VM Enforcer logs:

```shell
cat /var/log/aquasec.log
```

## Troubleshooting the VM Enforcer RPM deployment or upgrade

1. After the VM Enforcer RPM is deployed, check the service status:  
```shell
sudo systemctl status aqua-enforcer
```
2. If the service status is inactive, check the journalctl logs for more details.
```shell
sudo journalctl -u aqua-enforcer.service
```

## Uninstall VM Enforcer
Execute the following command to uninstall the VM Enforcer `.rpm` package:

```shell
sudo rpm -e aqua-vm-enforcer
```
## Build a VM Enforcer RPM package (optional: not required to deploy VM Enforcer)
To build a rpm package for VM-Enforcer:

1. Update the RPM scripts as required.
2. Update the RPM version in `nfpm.yaml`.
3. Upload the VM-Enforcer archive to `archives` folder.
4. Create environment variables, `RPM_ARCH` and `RPM_VERSION`
    
```shell
export RPM_ARCH=amd64 #change to arm64 for arm based systems
export RPM_VERSION=6.0.0 #mention version for VM Enforcer
```

5. Download NFPM (RPM Package Creator).
    
```shell
curl -sfL https://install.goreleaser.com/github.com/goreleaser/nfpm.sh | sh
```

6. Build the RPM package:
    
```shell
mkdir -p pkg
./bin/nfpm pkg --packager rpm --target ./pkg/
```