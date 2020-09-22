## Aqua Scanner

* The primary function of the Aqua scanner (or simply "scanner") is to scan the following types of objects for security issues:
  - Container images (From Registries and Local Host)
  - Cloud Foundry (CF) applications
  - Functions (serverless)

## Prerequisites
 - AQUA_SCANNER_USERNAME
    - Base64 Encoded aqua scanner username
 - AQUA_SCANNER_PASSWORD
    - Base64 Encoded aqua scanner password
 - AQUA_SERVER
    - Base64 Encoded aqua server URL/IP followed by HTTPS port number
## Considerations
 - Please deploy a scanner closure to your registry to quickly pull any images that requires scanning.
## Deploy Aqua Scanner

Step 1-3 are only required if you are deploying the Enforcer in a cluster that doesn't have the Aqua's namespace and service-account. Otherwise, you can start with step 4.

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

3. **Create platform specific RBAC**

   * RBAC definitions can vary between platforms. Please choose the right aqua_sa.yaml for your platform

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/<<platform>>/aqua_sa.yaml
   ```

4. **Create Scanner secrets**

   As specified in the prerequisites please do update the scanner secrets manifest file with appropriate values before apply.

   ```shell
   $ kubectl aply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_008_scanner/001_scanner_secrets.yaml
   ```

5. **Deploy Scanner**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_008_scanner/002_scanner_deploy.yaml
   ```