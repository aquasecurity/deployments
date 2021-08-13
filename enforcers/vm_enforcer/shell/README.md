# Deploy VM Enforcer Using Shell Scripts

## Overview

You can deploy VM Enforcer on your VM using the shell script provided by Aqua.

## Prerequisites
- Create and deploy the golden image on the VM
- Deploy a VM containing a VM Enforcer

For detailed instructions on these, refer to product documentation, [VM Enforcer Golden Image](https://docs.aquasec.com/docs/vm-enforcer-golden-image).

## Deploy VM Enforcer Deployment Using Shell Script

Execute the following shell script [Install_vme.sh](./Install_vme.sh) to deploy VM Enforcer on the execution VM.

```shell
sudo ./install_vme.sh [flags]
```

### Deployment modes

Deployment of VM Enforcer is supported by two modes as explained below.

#### Online mode 
 
Deploying VM Enforcer in the online mode can download the archive file from aqua and stores in the current directory automatically. You should add the following flags in the `Install_vme.sh` script to deploy VM Enforcer.

```shell
sudo ./install_vme.sh [flags]

Flags:
-v, --version  string         Aqua Enforcer version
-g, --gateway  string         Aqua Gateway address
-t, --token    string         Aqua Enforcer token

-d, --download	     boolean  download artifacts from aquasec
-u, --aqua-username  string	  Aqua username
-p, --aqua-password  string	  Aqua password
```

#### Offline mode

In this mode, You should store archive file locally on the same directory. You should add the following flags in the `Install_vme.sh` script to deploy VM Enforcer.

```shell
sudo ./install_vme.sh [flags]

Flags:
-v, --version  string         Aqua Enforcer version
-g, --gateway  string         Aqua Gateway address
-t, --token    string         Aqua Enforcer token
```