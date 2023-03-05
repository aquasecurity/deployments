
# Deploy Aqua Windows Enforcer using manifests
## Overview

This repository shows the manifest yaml files required to deploy Aqua Widnows Enforcer on the following Kubernetes platforms:
* AKS 

Before you follow the deployment steps explained below, Aqua strongly recommends you refer the product documentation, [Deploy Aqua Enforcer(s)](https://docs.aquasec.com/docs/deploy-k8s-aqua-enforcers) for detailed information.

## Prerequisites for manifest deployment

- Your Aqua credentials: username and password
- Access to Aqua registry to pull images
- The target Enforcer Group token 
- Access to the target Aqua gateway 

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

You may consider the following options for deploying the Aqua Enforcer:

- Gateway
  
  - To connect with an external Gateway, update the **AQUA_SERVER** value with the gateway endpoint address in the *002_aqua_windows_enforcer_configMaps.yaml* configMap manifest file.

## Supported platforms
| < PLATFORM >              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| aks | Microsoft Azure Kubernetes Service (AKS)    |


## Pre-deployment
You can skip any of the steps if you have already performed.

**Step 1. Create a namespace (or an OpenShift project) by name aqua (if not already done).**

   ```SHELL
   kubectl create namespace aqua
   ```

**Step 2. Create a docker-registry secret (if not already done).**

```SHELL
kubectl create secret docker-registry aqua-registry \
--docker-server=registry.aquasec.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email> \
-n aqua
   ```

**Step 3. Create a service account and RBAC for your deployment platform (if not already done).** Replace the platform name from [Supported platforms](#supported-platforms).

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/enforcers/windows_enforcer/kubernetes_and_openshift/manifests/001_aqua_windows_enforcer_rbac/aks/aqua_sa.yaml
   ```

## Deploy Aqua Enforcer using manifests

**Step 1. Create secrets for deployment**

   * Create the token secret that authenticates the Aqua Windows Enforcer over the Aqua Server.

      ```SHELL
      kubectl create secret generic enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
      ```

                                        (or)

     * Download, edit, and apply the secrets.

      ```SHELL
      kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/enforcers/windows_enforcer/kubernetes_and_openshift/manifests/003_aqua_windows_enforcer_secrets.yaml
      ```    

**Step 2. Deploy directly or download, edit, and apply ConfigMap as required.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/enforcers/windows_enforcer/kubernetes_and_openshift/manifests/002_aqua_windows_enforcer_configMap.yaml
```

**Step 3. Deploy Aqua Enforcer as daemonset.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/enforcers/windows_enforcer/kubernetes_and_openshift/manifests/004_aqua_windows_enforcer_daemonset.yaml
```
