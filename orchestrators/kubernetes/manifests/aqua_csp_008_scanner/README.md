## Aqua Scanner

* The primary function of the Aqua scanner (or simply "scanner") is to scan the following types of objects for security issues:
  - Container images (From Registries and Local Host)
  - Cloud Foundry (CF) applications
  - Functions (serverless)

## Prerequisites

Aqua scanner needs a username and password with a scanner role to authenticate itself over the server. Please define all the secrets in base64 encoding.
   - AQUA_SCANNER_USERNAME
      - Aqua scanner username from user management section in server web UI
   - AQUA_SCANNER_PASSWORD
      - Aqua scanner password from user management section in server web UI
   - AQUA_SERVER
      - Aqua server URL or IP followed by HTTPS port number.

## Considerations
 - Please deploy a scanner close to your registry for low latency and improved scanning throughput.
## Deploy Aqua Scanner

Step 1-3 is only required if you are deploying the Enforcer in a cluster that doesn't have the Aqua's namespace and service-account. Otherwise, you can start with step 4.

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