<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Deploy Aqua Cloud-Connector using manifests

## Overview
When deployed on local clusters, i.e., clusters on which Aqua Platform is not deployed, the Aqua Cloud
Connector establishes a secure connection to the Aqua Platform console, giving Aqua Platform remote
access to resources on the local clusters.

**Step 1. Create a namespace by name aqua (if not already done).**

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
 
**Step 3. (Optional) Create a service account and RBAC for your deployment platform (if not already done).**

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/001_cloud_connector_aqua_sa.yaml
   ```   

## Deploy Aqua Cloud-Connector using manifests
   
**Step 1. Create the secrets manually or download, edit, and apply the secrets.** Provide base64 username and password values for consoleI

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/002_cloud_connector_secrets.yaml
   ```

**Step 2. Deploy directly or download, edit, and run the deployment configMaps**

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/003_cloud_connector_configmap.yaml
   ```

**Step 3. Deploy Cloud-Connector Deployment** 

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/cloud_connector/kubernetes_and_openshift/manifests/004_cloud_connector_deployment.yaml
   ```
