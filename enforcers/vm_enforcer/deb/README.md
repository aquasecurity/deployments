# Deploy VM Enforcer using DEB Package

## Overview
Debian is a popular and freely-available computer operating system that uses the Linux kernel and other program components obtained from the GNU project. 

You can use DEB package to deploy a VM Enforcer on one or more VMs (hosts).

## Prerequisites
Following packages are required for installing the VM Enforcer DEB package:
* wget
* tar
* jq
* runc

## Deploy VM Enforcer
| Release Number      |  Build Number          |
| ------------------- | ------------------------|
| 6.5.21326.26.1      | 6.5.21336 |

**Step 1. Download the DEB package for your architecture, using an authorized username and password.**


   * **x86_64/amd64:**
  
        ```shell
       wget -v https://download.aquasec.com/host-enforcer/<release-number>/aqua-vm-enforcer-<build-number>.x86_64.deb \
        --user=<Username> \
        --ask-password
       ```
   * **arm64:**
  
     ```shell
     wget -v https://download.aquasec.com/host-enforcer/<release-number>/aqua-vm-enforcer-<build-number>.aarch64.deb \
      --user=<Username> \
      --ask-password
     ```

Make sure to replace the `<release-number>` and `<build-number>` with the relevant versions (example: 6.5.0 and 6.5.21215).


**Step 2. Copy the downloaded DEB package to the target VM(s).**


**Step 3. Write the `aquavmenforcer.json` configuration file.**

```shell
sudo mkdir -p /etc/conf/
sudo touch /etc/conf/aquavmenforcer.json
```

**Step 4. Run the following command with the relevant values for:**

   * `GATEWAY_HOSTNAME` and `PORT`: Aqua Gateway host/IP address and port
   * `TOKEN_VALUE`: Enforcer group token
   * `AQUA_TLS_VERIFY_VALUE`: *(Optional)* false\true. Set up the enforcer with tls-verify optionally. This configuration is **MANDATORY** for aqua **cloud** users, by setting up with value `true`.
   
   ```shell
   sudo tee /etc/conf/aquavmenforcer.json << EOF
   {
       "AQUA_GATEWAY": "{GATEWAY_HOSTNAME}:{PORT}",
       "AQUA_TOKEN": "{TOKEN_VALUE}",
       "AQUA_TLS_VERIFY": {AQUA_TLS_VERIFY_VALUE}
   }
   EOF
   ```

**Step 5. Deploy the DEB package.**

```shell
sudo dpkg -i /path/to/aqua-vm-enforcer-{version}.{arch}.deb
```

## Upgrade

To upgrade VM Enforcer using the DEB package:

1. Download the (updated) DEB package. Refer to step 1 in the [Deploy VM Enforcer](#deploy-vm-enforcer) section.
2. Upgrade VM Enforcer.

```shell
sudo dpkg -i /path/to/aqua-vm-enforcer-<version>.<arch>.deb
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

If the service status is inactive or showing any errors, you can check the journalctl logs for more details.

```shell
sudo journalctl -u aqua-enforcer.service
```
   
## Uninstall
Uninstall the VM Enforcer DEB package:

```shell
sudo dpkg -r aqua-vm-enforcer
```

## Build a DEB package (optional)

To Build a DEB package for VM Enforcer:
1. Update the DEB scripts as required.
2. Update the DEB version in `nfpm.yaml`.
3. Upload the VM Enforcer archive to `archives` folder.
4. Create environment variables, `DEB_ARCH` and `DEB_VERSION`.

```shell
export DEB_ARCH=amd64 #change to arm64 for arm based systems
export DEB_VERSION=2.10.0 #mention version for VM Enforcer
```

5. Download NFPM (DEB Package Creator).

```shell
echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | sudo tee /etc/apt/sources.list.d/goreleaser.list
sudo apt update
sudo apt install nfpm
```

6. Build the DEB package.

```shell
mkdir -p pkg
nfpm pkg --packager deb --target ./pkg/
```
