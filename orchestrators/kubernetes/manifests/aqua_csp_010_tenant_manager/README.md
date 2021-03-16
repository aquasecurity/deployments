## Deploy the Aqua Tenant Manager

Steps 1-3 are required only if you are deploying the Tenant Manager in a cluster that doesn't have the Aqua's namespace and service-account. Otherwise, you can start with step 4.

1. **Create namespace**
   
   ```SHELL
   $ kubectl create namespace aqua
   ```
2. **Create the docker-registry secret**

   ```SHELL
   $ kubectl create secret docker-registry aqua-registry \
   --docker-server=registry.aquasec.com \
   --docker-username=<your-name> \
   --docker-password=<your-pword> \
   --docker-email=<your-email> \
   -n aqua
   ```

3. **Create platform-specific RBAC**

   RBAC definitions can vary between platforms. Please choose the right aqua_sa.yaml for your platform

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/<<platform>>/aqua_sa.yaml
   ```

4. **Create Tenant Manager secrets**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_010_tenant_manager/001-tm-secret.yaml
   ```

5. **Deploy the Tenant Manager database config map**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_010_tenant_manager/001-tm-db-config-map.yaml
   ```
   
6. **Deploy the Tenant Manager database PVC**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_010_tenant_manager/001-tm-db-pvc.yaml
   ```   
   
7. **Deploy the Tenant Manager database**
   
      ```shell
      $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_010_tenant_manager/001-tm-db.yaml
      ```
   
8. **Deploy the Tenant Manager service**
   
      ```shell
      $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_010_tenant_manager/001-tm-deploy.yaml
      ```
