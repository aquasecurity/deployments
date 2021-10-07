# Deploy VM Enforcer using Shell Scripts


## Overview

You can deploy VM Enforcer on your execution VM using the shell script provided by Aqua. This procedure is supported for the Linux platform only.

## Deployment


**Step 1. Clone Aqua VM Enforcer shell repo.**

```shell
git clone --branch 6.5 https://github.com/aquasecurity/deployments.git
cd deployments/enforcers/vm_enforcer/shell/
chmod +x ./install_vme.sh
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

-d, --download	              download artifacts from aquasec
-u, --aqua-username  string	  Aqua username
-p, --aqua-password  string	  Aqua password

TLS verify Flag (Optional):

-tls, --aqua-tls-verify aqua_tls_verify
```

#### Offline mode

**Prerequisite:** You should download archive file and aqua templates from aqua repository manually and store in the current directory. 

Add the following flags in the `Install_vme.sh` script to deploy VM Enforcer in the offline mode.

```shell
sudo ./install_vme.sh [flags]

Flags:
-v, --version  string         Aqua Enforcer version
-g, --gateway  string         Aqua Gateway address
-t, --token    string         Aqua Enforcer token

TLS verify Flag (Optional):
-tls, --aqua-tls-verify aqua_tls_verify
```

## Uninstall

```
cd deployments/enforcers/vm_enforcer/shell/
chmod +x ./install_vme.sh
sudo ./uninstall_vme.sh
```