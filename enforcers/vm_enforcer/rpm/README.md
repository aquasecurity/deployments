# Deploy VM Enforcer using RPM Package

## Overview
Red Hat Linux and its derivatives such as CentOS and Fedora use RPM Package Manager to manage and install software. RPM also refers to the `rpm`, `yum` and `dnf` commands and `.rpm` file format. 

You can use RPM package to deploy a VM Enforcer on one or more VMs (hosts).

## Prerequisites
Following packages are required for installing VM Enforcer `.rpm` package:
* wget
* tar
* jq
* runc

## Deploy VM Enforcer
| Build Number        | Release Number          |
| ------------------- | ------------------------|
| 6.5.preview9 | 6.5.preview9   |

**Step 1. Download the RPM package for your architecture, using an authorized username and password.**


   * **x86_64/amd64:**
  
        ```shell
       wget -v https://download.aquasec.com/host-enforcer/<release-number>/aqua-vm-enforcer-<build-number>.x86_64.rpm \
        --user=<Username> \
        --ask-password
       ```
   * **arm64:**
  
     ```shell
     wget -v https://download.aquasec.com/host-enforcer/<release-number>/aqua-vm-enforcer-<build-number>.aarch64.rpm \
      --user=<Username> \
      --ask-password
     ```

Make sure to replace the `<release-number>` and `<build-number>` with the relevant versions (example: 6.5.0 and 6.5.21215).


**Step 2. Copy the downloaded RPM package onto the target VM(s).**


**Step 3. Write the `aquavmenforcer.json` configuration file**

```shell
sudo mkdir -p /etc/conf/
sudo touch /etc/conf/aquavmenforcer.json
```

**Step 4. Run the following command with the relevant values for:**

   * `GATEWAY_HOSTENAME` and `PORT`: Aqua Gateway host/IP address and port
   * `TOKEN_VALUE`: Enforcer group token
   * `AQUA_TLS_VERIFY_VALUE`: false\true, Set up the enforcer with tls-verify. This is optional, but it is **MANDATORY** for aqua **cloud** users with value `true`.
   
   ```shell
   sudo tee /etc/conf/aquavmenforcer.json << EOF
   {
       "AQUA_GATEWAY": "{GATEWAY_HOSTENAME}:{PORT}",
       "AQUA_TOKEN": "{TOKEN_VALUE}",
       "AQUA_TLS_VERIFY": {AQUA_TLS_VERIFY_VALUE}
   }
   EOF
   ```

**Step 5. Deploy the RPM**

```shell
sudo rpm -ivh /path/to/aqua-vm-enforcer-{version}.{arch}.rpm
```

## Upgrade

To upgrade the VM Enforcer using the RPM package:

1. Download the (updated) RPM package. Refer to step 1 in the [Deploy VM Enforcer](#deploy-vm-enforcer) section.
2. Upgrade the VM Enforcer using the following command:

```shell
sudo rpm -U /path/to/aqua-vm-enforcer-<version>.<arch>.rpm
```

## Troubleshooting

### Check the logs

Check the VM Enforcer application logs.

```shell
cat /opt/aquasec/tmp/aquasec.log
```

### Check the Journal

1. Check the service status.
   
```shell
sudo systemctl status aqua-enforcer
```

2. Check the journal logs.

If the service status is inactive or shows any errors, you can check the journalctl logs for more details:

```shell
sudo journalctl -u aqua-enforcer.service
```
   
## Uninstall
To uninstall the VM Enforcer `rpm` package:

```shell
sudo rpm -e aqua-vm-enforcer
```

## Build an RPM package (optional)

To Build an RPM package for VM-Enforcer:
1. Update the RPM scripts as required.
2. Update the RPM version in `nfpm.yaml`.
3. Upload the VM-Enforcer archive to `archives` folder.
4. Create environment variables of `RPM_ARCH` and `RPM_VERSION`.

```shell
export RPM_ARCH=amd64 #change to arm64 for arm based systems
export RPM_VERSION=6.5.0 #mention version for VM Enforcer
```

5. Download NFPM (RPM Package Creator).

```shell
curl -sfL https://install.goreleaser.com/github.com/goreleaser/nfpm.sh | sh
```

6. Build the RPM.

```shell
mkdir -p pkg
./bin/nfpm pkg --packager rpm --target ./pkg/
```