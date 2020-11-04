## Aqua Scanner

The primary function of the Aqua scanner (or simply "scanner") is to scan the following types of objects for security issues:
  - Container images (From Registries and Local Host)
  - Tanzu applications -- formerly called Cloud Foundry (CF) applications
  - Functions (serverless)

## Prerequisites

The Aqua scanner needs the username and password of a user with the scanner role to authenticate itself over the Aqua Server. Users are defined in the Aqua Enterprise UI under Administration > **Access Management**. Please define these secrets in base64 encoding:
   - `AQUA_SCANNER_USERNAME`
   - `AQUA_SCANNER_PASSWORD`
   - `AQUA_SERVER` (the Aqua Server URL or IP followed by the HTTPS port number)

## Considerations
 - You should deploy the scanner close to your registry for low latency and improved scanning throughput.

## Deploy the Aqua Scanner

Steps 1-3 are required only if you are deploying the scanner in a cluster that doesn't have the Aqua's namespace and service-account. Otherwise, you can start with step 4.

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

4. **Create Scanner secrets**

   As specified in the prerequisites above, please update the scanner secrets manifest file with appropriate values before applying it.

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_008_scanner/001_scanner_secrets.yaml
   ```

5. **Deploy the Scanner**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_008_scanner/002_scanner_deploy.yaml
   ```