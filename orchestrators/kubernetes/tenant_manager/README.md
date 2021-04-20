## Deploy the Aqua Tenant Manager

Steps 1-3 are required only if you are deploying the Tenant Manager in a cluster that doesn't have the Aqua's namespace and service-account. Otherwise, you can start with step 4.
If you wish to deploy the Tenant Manager with an external database:
*   Skip steps 5-7
*   Edit the secret for database password in step 4
*   Edit the config map in step 8 with the relevant host/user-name/password


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
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/<<platform>>/aqua_sa.yaml
   ```

4. **Create Tenant Manager database password secret**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/001-tm-secret.yaml
   ```

5. **Deploy the Tenant Manager database config map**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/002-tm-db-config-map.yaml
   ```
   
6. **Deploy the Tenant Manager database PVC**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/003-tm-db-pvc.yaml
   ```   
   
7. **Deploy the Tenant Manager database**
   
      ```shell
      $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/004-tm-db.yaml
      ```

8. **Deploy Tenant Manager config map**
    ```shell
    $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/005-tm-config-map.yaml
    ```
   
9. **Deploy the Tenant Manager service**
   
      ```shell
      $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/tenant_manager/006-tm-deploy.yaml
      ```
