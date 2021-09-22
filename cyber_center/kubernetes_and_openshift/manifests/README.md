# Deploy Aqua CyberCenter using manifests

## Overview

This repository shows the manifest yaml files required to deploy Aqua CyberCenter on the following Kubernetes platforms:
* Kubernetes
* OpenShift
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Aqua strongly recommends you refer to the product documentation, [Aqua CyberCenter](https://docs.aquasec.com/docs/cybercenter-description) for detailed information.

## Specific OpenShift notes
The deployment commands shown below use the **kubectl** cli, you can also deploy using the **oc** cli commands, to work on all platforms including OpenShift.

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
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/cybercenter/kubernetes_and_openshift/manifests/001_cybercenter_serviceAccount.yaml
```

## Deploy CyberCenter using manifests

**Step 1. Deploy Aqua CyberCenter.**

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/cybercenter/kubernetes_and_openshift/manifests/002_cybercenter_deploy.yaml
```
