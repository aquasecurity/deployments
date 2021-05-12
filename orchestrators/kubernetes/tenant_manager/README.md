# Description

Like many enterprises, you may have separate Aqua Enterprise instances deployed in different groups or departments. The Aqua Tenant Manager is an optional application that allows you to create security policies and distribute them to multiple domains (groups) of these instances (tenants). This ensures uniformity in the application of all security policies, or those that you select, across your organization. 

The Tenant Manager is a web-based application with a simple, intuitive user interface (UI). This enables a single administrator to maintain your enterprise's security policies quite easily.

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

**Step 3. Create the RBAC for your deployment platform (if not already done)**

| Platform            | Command                                                                                                                                                      |
|---------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Kubernetes (native) | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/kubernetes/aqua_sa.yaml |
| AKS                 | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/aks/aqua_sa.yaml        |
| EKS                 | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/eks/aqua_sa.yaml        |
| GKE                 | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/gke/aqua_sa.yaml        |
| ICP                 | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/icp/aqua_sa.yaml        |
| OpenShift           | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/openshift/aqua_sa.yaml  |
| Rancher             | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/rancher/aqua_sa.yaml    |
| TKG                 | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/tkg/aqua_sa.yaml        |
| TKGI                | $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/tkgi/aqua_sa.yaml       |

# Deployment

The Tenant Manager supports both the Aqua packaged DB and an external DB installation. Follow the appropriate set of instructions:
   - [Deploy the Tenant Manager with the Aqua packaged DB](#Deploy-the-Tenant-Manager-with-the-Aqua-packaged-DB)
   - [Deploy the Tenant Manager with an external DB](#Deploy-the-Tenant-Manager-with-an-external-DB)

## Deploy the Tenant Manager with the Aqua packaged DB 

**Step 1. Create the Tenant Manager database password secret**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/tenant_manager/001-tm-secret.yaml
   ```

**Step 2. Deploy the Tenant Manager database ConfigMap**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/tenant_manager/002-tm-db-config-map.yaml
   ```
   
**Step 3. Deploy the Tenant Manager database PVC**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/tenant_manager/003-tm-db-pvc.yaml
   ```   
   
**Step 4. Deploy the Tenant Manager DB**
   
   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/tenant_manager/004-tm-db.yaml
   ```
   
**Step 5. Deploy the Tenant Manager ConfigMap**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/tenant_manager/005-tm-config-map.yaml
   ```

**Step 6. Deploy the Tenant Manager service**
   
   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/tenant_manager/006-tm-deploy.yaml
   ```

## Deploy the Tenant Manager with an external DB 

**Step 1. Configure and deploy the Tenant Manager ConfigMap**

Download and update the ConfigMap [005-tm-config-map.yaml](./005-tm-config-map.yaml) with the relevant DB host, username, and password.
Then apply the ConfigMap:

   ```shell
   $ kubectl apply -f 005-tm-config-map.yaml
   ```
   
**Step 2. Deploy the Tenant Manager service**
   
   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.0/orchestrators/kubernetes/tenant_manager/006-tm-deploy.yaml
   ```
