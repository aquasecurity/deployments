# Deploy Tenant Manager using manifests

## Overview

The Aqua Tenant Manager is an optional application that allows creating security policies and distribute them to multiple domains (groups) of these instances (tenants). This ensures uniformity in the application of all security policies, or those that are selected, across the organization. 

The Tenant Manager is a web-based application with a simple, intuitive user interface (UI). This enables a single administrator to maintain enterprise's security policies quite easily.

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

> You can skip any of the steps that you have already performed.

**Step 1. Create the aqua namespace (if not already done)**
   
```SHELL
$ kubectl create namespace aqua
```

**Step 2. Create the docker-registry secret (if not already done)**

```SHELL
$ kubectl create secret docker-registry aqua-registry \
--docker-server=registry.aquasec.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email> \
-n aqua
```

**Step 3. Create a service account and RBAC for your deployment platform (if not already done).** Replace the platform name from [Supported platforms](#supported-platforms).

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/tenant_manager/kubernetes_and_openshift/manifests/002_tm_RBAC/< PLATFORM >/aqua_sa.yaml
```

## Deployment

The Tenant Manager supports both the Aqua packaged DB and an external DB installation. Follow the appropriate set of instructions:
   - [Deploy the Tenant Manager with the Aqua packaged DB](#Deploy-the-Tenant-Manager-with-the-Aqua-packaged-DB)
   - [Deploy the Tenant Manager with an external DB](#Deploy-the-Tenant-Manager-with-an-external-DB)

### Deploy the Tenant Manager with the Aqua packaged DB 

**Step 1. Create the Tenant Manager database password secret**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/001-tm-secret.yaml
   ```

**Step 2. Deploy the Tenant Manager database ConfigMap**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/002-tm-db-config-map.yaml
   ```
   
**Step 3. Deploy the Tenant Manager database PVC**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/003-tm-db-pvc.yaml
   ```   
   
**Step 4. Deploy the Tenant Manager DB**
   
   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/004-tm-db.yaml
   ```
   
**Step 5. Deploy the Tenant Manager ConfigMap**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/005-tm-config-map.yaml
   ```

**Step 6. Deploy the Tenant Manager service**
   
   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/006-tm-deploy.yaml
   ```

### Deploy the Tenant Manager with an external DB 

**Step 1. Configure and deploy the Tenant Manager ConfigMap**

Download and update the ConfigMap [005-tm-config-map.yaml](./005-tm-config-map.yaml) with the relevant DB host, username, and password.
Then apply the ConfigMap:

   ```shell
   $ kubectl apply -f 005-tm-config-map.yaml
   ```
   
**Step 2. Deploy the Tenant Manager service**
   
   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/006-tm-deploy.yaml
   ```