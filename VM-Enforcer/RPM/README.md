<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Installing VM-Enforcer using RPM

## Contents

- [Installing VM-Enforcer using RPM](#installing-vm-enforcer-using-rpm)
  - [Contents](#contents)
  - [Description](#description)
  - [Install VM-Enforcer RPM](#install-vm-enforcer-rpm)
      - [Download VM-Enforcer RPM package](#download-vm-enforcer-rpm-package)
      - [Configuring Gateway Address and Enforcer group token](#configuring-gateway-address-and-enforcer-group-token)
      - [Install RPM](#install-rpm)
  - [Upgrade VM-Enforcer using RPM package](#upgrade-vm-enforcer-using-rpm-package)
  - [Checking VM-Enforcer application logs](#checking-vm-enforcer-application-logs)
  - [Troubleshooting VM-Enforcer RPM Installation/Upgrade](#troubleshooting-vm-enforcer-rpm-installationupgrade)
  - [Building VM Enforcer RPM package](#building-vm-enforcer-rpm-package)

## Description
The RPM Package Manager (RPM) is a powerful package management system used by Red Hat Linux and its derivatives such as CentOS and Fedora. RPM also refers to the rpm command and .rpm file format. 

## Install VM-Enforcer RPM
#### Download VM-Enforcer RPM package

Download RPM package from aqua downloads with autorized user and password
For amd64 systems:
```shell
$ curl https://download.aquasec.com/internal/host-enforcer/5.3.0/aqua-vm-enforcer-5.3.0.x86_64.rpm -u <Username>
```
For arm64 systems:
```shell
$ curl https://download.aquasec.com/internal/host-enforcer/5.3.0/aqua-vm-enforcer-5.3.0.aarch64.rpm -u <Username>
```

Copy the downloaded rpm package to the respective VMs and follow the below instructions for installing and configuring VM-Enforcers

#### Configuring Gateway Address and Enforcer group token

Creating aquasec.json file for configuaration 
```shell
$ sudo mkdir -p /etc/conf/ && touch /etc/conf/aquasec.json
```

Change the `<GATEWAY_HOSTENAME>:<PORT>` to aqua gateway host/IP address, gateway port and Change `<TOKEN VALUE>` to the enforcer group token in the below command execute it 
```shell
$ sudo tee >/etc/conf/aquasec.json <<END
{
  "AQUA_GATEWAY": "<GATEWAY_HOSTENAME>:<PORT>",
  "AQUA_TOKEN": "<TOKEN VALUE>"
}
END
```

#### Install RPM

Once the configuaration completes install the rpm package using below command

```shell
$ sudo rpm -ivh /path/to/aqua-vm-enforcer-{version}.{arch}.rpm
```
## Upgrade VM-Enforcer using RPM package

Download updated RPM package from aqua downloads with autorized user and password

For amd64 systems:
```shell
$ curl https://download.aquasec.com/internal/host-enforcer/5.3.0/aqua-vm-enforcer-5.3.0.x86_64.rpm -u <Username>
```
For arm64 systems:
```shell
$ curl https://download.aquasec.com/internal/host-enforcer/5.3.0/aqua-vm-enforcer-5.3.0.aarch64.rpm -u <Username>
```

Once the package completes download, upgrade VM-Enforcer using below command

```shell
$ sudo rpm -U /path/to/aqua-vm-enforcer-{version}.{arch}.rpm
```

## Checking VM-Enforcer application logs
For checking logs of the VM-Enforcer
```shell
$ less /var/log/aquasec.log
```
## Troubleshooting VM-Enforcer RPM Installation/Upgrade

After vvm-enforcer rpm installs you can check the service status using below command
```shell
$ sudo systemctl status aqua-enforcer
```
If Service status is inactive and you can check the journalctl logs for more details
```shell
$ sudo journalctl -u aqua-enforcer.service
```

## Building VM Enforcer RPM package 

1) Update the RPM scripts as required
2) Update the RPM version in `nfpm.yaml`
3) Change the architecture in `nfpm.yaml` if required (supported values: `x86_64`, `arm64`)
4) Download NFPM (RPM Package Creator)
```shell
curl -sfL https://install.goreleaser.com/github.com/goreleaser/nfpm.sh | sh
```
5) Build the RPM
```shell
./bin/nfpm pkg --packager rpm --target ./pkg/
```
