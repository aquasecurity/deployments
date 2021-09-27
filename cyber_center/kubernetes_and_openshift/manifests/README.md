# Deploy Aqua CyberCenter using manifests

## Overview

This repository shows the manifest yaml files required to deploy the Aqua CyberCenter on the following Kubernetes platforms:
* Kubernetes
* OpenShift
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Aqua strongly recommends you refer to the product documentation, [Deploy Offline CyberCenter](https://docs.aquasec.com/v6.5/docs/deploy-offline-cybercenter) for detailed information.

## Specific OpenShift notes
The deployment commands shown below use the **kubectl** cli. You can also deploy using the **oc** cli commands, to work on all platforms including OpenShift.

## Prerequisites
* Your Aqua credentials: username and password
* Your Aqua Enterprise License Token

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

### CyberCenter image for deployment

The CyberCenter image, **cc-standard:latest** is added in the [CyberCenter deploy yaml file](./002_cybercenter_deploy.yaml) at the line 40, for support on vulnerabilities related to all the operating systems. Use the **cc-premium:latest** image to get support on vulnerabilities related to all the programming languages also.

### mTLS
To configure the CyberCenter with mTLS (mutual TLS) to have secure communication with server, refer to the product documentation, [Configure mTLS for the Offline CyberCenter](https://docs.aquasec.com/docs/configure-mtls-for-the-offline-cybercenter).

## Pre-deployment

You can skip any of the steps if you have already performed.

**Step 1. Create a namespace (or an OpenShift  project) by name aqua (if not already done).**

```SHELL
$ kubectl create namespace aqua
```

**Step 2. Create a docker-registry secret (if not already done).**

```SHELL
$ kubectl create secret docker-registry aqua-registry \
--docker-server=registry.aquasec.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email> \
-n aqua
```

**Step 3. Create a service account (if not already done).**

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/cyber_center/kubernetes_and_openshift/manifests/001_cybercenter_serviceAccount.yaml
```

## Deploy the CyberCenter using manifests

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/cyber_center/kubernetes_and_openshift/manifests/002_cybercenter_deploy.yaml
```