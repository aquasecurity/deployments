
# Deploy Aqua Enforcer using manifests
## Overview

This repository shows the manifest yaml files required to deploy Aqua Enforcer on the following Kubernetes platforms:
* Kubernetes 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Aqua strongly recommends you refer the product documentation, [Deploy Aqua Enforcer(s)](https://docs.aquasec.com/v6.5/docs/deploy-k8s-aqua-enforcers) for detailed information.

### Specific OpenShift notes
The deployment commands shown below, use the **kubectl** cli, however they can be easliy replaced with the **oc** cli commands, to work on all platforms including OpenShift.

## Prerequisites for manifest deployment

- Your Aqua credentials: username and password
- Access to Aqua registry to pull images
- The target Enforcer Group token 
- Access to the target Aqua gateway 

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/v6.5/docs/sizing-guide).

## Considerations

You may consider the following options for deploying the Aqua Enforcer:

- Mutual Auth / Custom SSL certs

  - Prepare the SSL cert for your Aqua Server domain to use your CA authority. You should modify the manifest deployment files with the mounts to the SSL secrets files. 

- Gateway
  
  - To connect with an exteranl Gateway, update the **AQUA_SERVER** value with the gateway endpoint address in the *002_aqua_enforcer_configMaps.yaml* configMap manifest file.

## Supported platforms
| < PLATFORM >              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| aks | Microsoft Azure Kubernetes Service (AKS)    |
| eks | Amazon Elastic Kubernetes Service (EKS) |
| gke | Google Kubernetes Engine (GKE) |
| ibm | IBM Cloud Private (ICP) |
| k3s | fully CNCF certified Kubernetes |
| native_k8s | Kubernetes |
| openshift | OpenShift (Red Hat) |
| rancher | Rancher / Kubernetes |
| tkg | VMware Tanzu Kubernetes Grid (TKG) |
| tkgi | VMware Tanzu Kubernetes Grid Integrated Edition (TKGI) |

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
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/aqua_enforcer/kubernetes_and_openshift/manifests/001_aqua_enforcer_rbac/< PLATFORM >/aqua_sa.yaml
   ```

## Deploy Aqua Enforcer using manifests

**Step 1. Create secrets for deployment**

   * Create the token secret that authenticates the Aqua Enforcer over the Aqua Server.

      ```SHELL
      kubectl create secret generic enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
      ```

                                        (or)

     * Download, edit, and apply the secrets.

      ```SHELL
      kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/aqua_enforcer/kubernetes_and_openshift/manifests/003_aqua_enforcer_secrets.yaml
      ```    

**Step 2. Deploy directly or download, edit, and apply ConfigMap as required.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/aqua_enforcer/kubernetes_and_openshift/manifests/002_aqua_enforcer_configMap.yaml
```

**Step 3. Deploy Aqua Enforcer as daemonset.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/aqua_enforcer/kubernetes_and_openshift/manifests/004_aqua_enforcer_daemonset.yaml
```

## Automate Aqua Enforcer deployment using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Aqua Enforcer using Manifests](#deploy-aqua-enforcer-using-manifests). Command shown in this section creates (downloads) manifests (yaml) files quickly and prepares them for the Aqua Enforcer deployment.

### Command Syntax

```SHELL
aquactl download enforcer [flags]
```

### Flags
You should pass the following deployment options through flags, as required.

#### Aquactl operation

Flag and parameter type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| -p or --platform, (string) (mandatory flag) | Orchestration platform to deploy Aqua Enterprise on. you should pass one of the following as required: **kubernetes, aks, eks, gke, icp, openshift, tkg, tkgi**    |
| * -v or --version
(string) (mandatory flag) | Major version of Aqua Enterprise to deploy. For example: **6.5** |
| -r or --registry (string) | Docker registry containing the Aqua Enterprise product images, it defaults to **registry.aquasec.com** |
| --pull-policy (string) | The Docker image pull policy that should be used in deployment for the Aqua product images, it defaults to **IfNotPresent** |
| --service-account (string) | Kubernetes service account name, it defaults to **aqua-sa** |
| -n, --namespace (string) | Kubernetes namespace name, it defaults to **aqua** |
| --output-dir (string) | Output directory for the manifests (YAML files), it defaults to **aqua-deploy**, the directory aquactl was launched in |

#### Aqua Enforcer configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --gateway-url (string) | Aqua Gateway URL (IP, DNS, or service name) and port, it defaults to **aqua-gateway:8443**|
| --token (string) | Deployment token for the Aqua Enforcer group, it defaults to **enforcer-token**|

The **--gateway-url** flag identifies an existing Aqua Gateway used to connect the Aqua Enforcer. This flag is not used to configure a new Gateway, as in *aquactl download all* or *aquactl download server*.

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
aquactl download enforcer --platform gke --version 6.5
```