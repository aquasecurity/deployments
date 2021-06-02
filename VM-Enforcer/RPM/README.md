<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Deploying the VM Enforcer using RPM

## Description
The RPM Package Manager (RPM) is a powerful package management system used by Red Hat Linux and its derivatives such as CentOS and Fedora. RPM also refers to the `rpm` command and `.rpm` file format. 

You can use RPM to deploy a VM Enforcer on one or more VMs (hosts).

## Deploy the VM Enforcer

1. Download the RPM package from Aqua Security, using an authorized user and password:
   1. For x86_64/amd64 systems:
    ```shell
    wget -v https://download.aquasec.com/internal/host-enforcer/6.0.0/aqua-vm-enforcer-6.0.0.x86_64.rpm --user=<Username> --ask-password
    ```
   2. For arm64 systems:
    ```shell
    wget -v https://download.aquasec.com/internal/host-enforcer/6.0.0/aqua-vm-enforcer-6.0.0.aarch64.rpm --user=<Username> --ask-password
    ```

2. Copy the downloaded RPM package to the VM(s) on which you want to deploy a VM Enforcer.

3. To configure the Gateway address and Enforcer group token, start by creating the `aquavmenforcer.json` configuration file:
    ```shell
    sudo mkdir -p /etc/conf/ && sudo touch /etc/conf/aquavmenforcer.json
    ```

4. In the command that follows, change the `<GATEWAY_HOSTENAME>:<PORT>` to the Aqua Gateway host/IP address and port, and change `<TOKEN VALUE>` to the Enforcer group token.
Then execute the command.
```shell
sudo tee /etc/conf/aquavmenforcer.json << EOF
{
    "AQUA_GATEWAY": "{GATEWAY_HOSTENAME}:{PORT}",
    "AQUA_TOKEN": "<{TOKEN VALUE}"
}
EOF
```

5. Deploy the RPM: Once the configuration completes, deploy the RPM package using this command:

    ```shell
    sudo rpm -ivh /path/to/aqua-vm-enforcer-{version}.{arch}.rpm
    ```

## Upgrade the VM Enforcer using the RPM package

1. Download the (updated) RPM package from Aqua Security, using an authorized user and password:
   1. For x86_64/amd64 systems:
    ```shell
    wget -v https://download.aquasec.com/internal/host-enforcer/6.0.0/aqua-vm-enforcer-{version}.x86_64.rpm --user=<Username> --ask-password
    ```
   2. For arm64 systems:
    ```shell
    wget -v https://download.aquasec.com/internal/host-enforcer/6.0.0/aqua-vm-enforcer-{version}.aarch64.rpm --user=<Username> --ask-password
    ```

    `version : change {version} to latest available vm-enforcer version and download`

2. Once the package has been downloaded, upgrade the VM Enforcer using this command:

```shell
    sudo rpm -U /path/to/aqua-vm-enforcer-{version}.{arch}.rpm
```

## Check the VM Enforcer application logs

To check the VM Enforcer logs:
  ```shell
  cat /var/log/aquasec.log
  ```

## Troubleshooting the VM Enforcer RPM deployment or upgrade

1. After the VM Enforcer RPM has been deployed, you can check the service status using this command:
    ```shell
    sudo systemctl status aqua-enforcer
    ```

2. If the service status is inactive, you can check the journalctl logs for more details:
    ```shell
    sudo journalctl -u aqua-enforcer.service
    ```

## Building a VM Enforcer RPM package (optional: not required for deploying the VM Enforcer)
The below instructions helps to build a rpm package for VM-Enforcer
1. Update the RPM scripts as required.
2. Update the RPM version in `nfpm.yaml`.
3. Upload the VM-Enforcer archive to `archives` folder.
4. Change the architecture in `nfpm.yaml` if required (supported values: `x86_64`, `arm64`).
5. Download NFPM (RPM Package Creator):
    ```shell
    curl -sfL https://install.goreleaser.com/github.com/goreleaser/nfpm.sh | sh
    ```
6. Build the RPM:
    ```shell
    ./bin/nfpm pkg --packager rpm --target ./pkg/
    ```