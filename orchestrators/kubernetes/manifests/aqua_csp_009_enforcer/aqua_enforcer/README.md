## The Enforcer Family

- Aqua Enforcer running as a DaemonSet deployment provides runtime security for your kubernetes workloads by blocking unauthrized deployments, monitor/restrict runtime activities and generate audit events for your review.

## Prerequisites

- Aqua registry access to pull images, Cluster access via kubectl, and RBAC authorization to deploy applications.

- Aqua Enforcer token copied from server UI for authentication. The token is provisioned to the Enforcer as a secret.

## Considerations

Please consider following options while deploying Aqua Enforcer DaemonSet:

- Mutual Auth / Custom SSL certs

  - If you want to enable mutual auth between aqua components or if you want to use your own SSL certificates. Please refer to SSL considerations https://docs.aquasec.com

- Gateway
  - By default Aqua enforcer will connect to an internal gateway over aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi cluster deployment please update the **AQUA_SERVER** value with the external gateway end-point address followed by port number in 001_aqua_enforcer_configMaps.yaml configMap manifest file.

- By default, enforcers are deployed in non-privileged mode and note that protection is only applied to new or restarted containers.

## Deploy Aqua Enforcer

Aqua Enforcer is an optional enforcement option that deployed as a daemon-set.

For more information please read https://docs.aquasec.com/docs/aqua-enforcer

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

4. **Define the configMap for the deployment.**

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/001_aqua_enforcer_configMaps.yaml
   ```
   
5. **Create secrets for the Enforcer deployment.**

   * The only mandatory secret is the **token** that authenticates the Enforcer over Aqua server.

   ```SHELL
   $ kubectl create secret generic aqua-kube-enforcer-token -from-literal=enforcer-token=<token_from_server_ui>
   ```

   * You can also manually modify the secret manifest file and use kubectl apply to create token secret
   ```SHELL
   $ https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/002_aqua_enforcer_secrets.yaml
   ```

6. **Create Aqua Enforcer DaemonSet**

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/003_aqua_enforcer_daemonset.yaml
   ```