# Deploy VM Enforcer using Shell Scripts


## Overview

You can deploy VM Enforcer on your execution VM using the shell script provided by Aqua. This procedure is supported for the Linux platform only.

## Deployment


**Step 1. Clone Aqua VM Enforcer shell repo.**

```shell
git clone https://github.com/aquasecurity/deployments.git
cd deployments/VM-Enforcer/shell/
```

**Step 2. Execute the following shell script to deploy VM Enforcer.**

```shell
sudo ./install_vme.sh [flags]
```

### Deployment modes

Deployment of VM Enforcer is supported by two modes as explained below.

#### Online mode

Deploying VM Enforcer in the online mode can download the archive file from aqua and stores in the current directory automatically. Add the following flags in the `Install_vme.sh` script to deploy VM Enforcer.


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

**Prerequisite:** You should download archive file from aqua repository manually and store in the current directory. 

Add the following flags in the `Install_vme.sh` script to deploy VM Enforcer in the offline mode.

```shell
sudo ./install_vme.sh [flags]

Flags:
-v, --version  string         Aqua Enforcer version
-g, --gateway  string         Aqua Gateway address
-t, --token    string         Aqua Enforcer token
```