# Deploy VM Enforcer using Shell Scripts


## Overview

You can deploy VM Enforcer on your execution VM using the shell script provided by Aqua. This procedure is supported for the Linux platform only.

## Deployment modes

Deployment of VM Enforcer is supported by two modes as explained below.
### Online mode

Deploying VM Enforcer in the online mode can download the archive file from aqua and stores in the current directory automatically. Add the following flags in the `Install_vme.sh` script to deploy VM Enforcer.

**Step 1. Clone Aqua VM Enforcer shell repo.**

```shell
  git clone --branch 6.5 https://github.com/aquasecurity/deployments.git
  cd deployments/enforcers/vm_enforcer/shell/
  chmod +x ./install_vme.sh
```

**Step 2. Execute the following shell script to deploy VM Enforcer.**

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
curl -s -o uninstall_vme.sh https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/vm_enforcer/shell/uninstall_vme.sh
chmod +x ./uninstall_vme.sh
sudo ./uninstall_vme.sh
```
