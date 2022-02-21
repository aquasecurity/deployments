# Deploy VM Enforcer using Shell Scripts


## Overview

You can deploy VM Enforcer on your execution VM using the shell script provided by Aqua. This procedure is supported for the Linux platform only.

## Deployment modes

Deployment of VM Enforcer is supported by two modes as explained below.
### Online mode

Deploying VM Enforcer in the online mode can download the archive file from aqua and stores in the current directory automatically. Add the following flags in the `Install_vme.sh` script to deploy VM Enforcer.

**Execute the following command to run and install VM Enforcer**
Switch to the root user and run:
```shell
  curl -s https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/shell/install_vme.sh | ENFORCER_VERSION=<value> GATEWAY_ENDPOINT=<value> TOKEN=<value> DOWNLOAD_MODE=<value> AQUA_USERNAME=<value> AQUA_PWD=<value> bash
```


**Variables description**

```shell

  ENFORCER_VERSION  string         Aqua Enforcer version
  GATEWAY_ENDPOINT  string         Aqua Gateway address
  TOKEN             string         Aqua Enforcer token

  DOWNLOAD_MODE     bool	         download artifacts from aquasec default value = true
  AQUA_USERNAME     string	       Aqua username
  AQUA_PWD          string	       Aqua password

  AQUA_TLS_VERIFY (Optional):

  AQUA_TLS_VERIFY   bool           default value = false
```

### Offline mode

**Prerequisite:** You should download archive file, aqua templates and aqua config from aqua repository manually and store in the current directory.

**Step 1: Download Archive**

```shell
  wget https://download.aquasec.com/host-enforcer/6.5.21336/aqua-host-enforcer.6.5.21336.tar --user=<Username> --ask-password
```

**Step 2: Download aqua templates and config files**

```shell
  curl -s -o aqua-enforcer.template.service https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/templates/aqua-enforcer.template.service
  curl -s -o aqua-enforcer.template.old.service https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/templates/aqua-enforcer.template.old.service
  curl -s -o run.template.sh https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/templates/run.template.sh
  curl -s -o aqua-enforcer-runc-config.json https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/templates/aqua-enforcer-runc-config.json
  curl -s -o aqua-enforcer-v1.0.0-rc2-runc-config.json https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/templates/aqua-enforcer-v1.0.0-rc2-runc-config.json
```

**Step 3: Download and Deploy VM Enforcer**

**Download Archive**

```shell
  curl -s -o install_vme.sh https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/shell/install_vme.sh
  chmod +x ./install_vme.sh
```

**Deploy VM Enforcer**

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
curl -s https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/shell/uninstall_vme.sh | bash
```
