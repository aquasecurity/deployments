## Aqua Enforcer

The Aqua Enforcer, running as a DaemonSet deployment, provides runtime security for your Kubernetes workloads by blocking unauthorized deployments, monitoring and restricting runtime activities, and generating audit events for your review. Deployment of Aqua Enforcers is optional. See the [Aqua Enterprise documentation portal](https://docs.aquasec.com/v5.3/) for more information.

## Prerequisites

- Aqua registry access to pull images, cluster access via kubectl, and RBAC authorization to deploy applications.

- The Aqua Enforcer deployment token copied from the Aqua Enterprise Server UI for authentication. The token is provisioned to the Enforcer as a secret.

## Considerations

Consider the following options for deploying the Aqua Enforcer DaemonSet:

- Mutual Auth / Custom SSL certs

  - If you want to enable mutual auth between Aqua Enterprise components, or if you want to use your own SSL certificates, refer to SSL considerations in the [Aqua Enterprise documentation portal](https://docs.aquasec.com/v5.3/).

- Gateway
  - By default, the Aqua Enforcer will connect to an internal gateway over the aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi-cluster deployment you will need to update the **AQUA_SERVER** value with the external gateway endpoint address, followed by the port number, in the 001_aqua_enforcer_configMaps.yaml configMap manifest file.

- By default, Enforcers are deployed in non-privileged mode. Protection is applied only to new or restarted containers.

## Deploy the Aqua Enforcer

Steps 1-3 are required only if you are deploying the Enforcer in a cluster that doesn't have Aqua's namespace and service-account. Otherwise, you can start with step 4.

1. **Create namespace**
   
   ```SHELL
   kubectl create namespace aqua
   ```
2. **Create the docker-registry secret**

   ```SHELL
   kubectl create secret docker-registry aqua-registry \
   --docker-server=registry.aquasec.com \
   --docker-username=<your-name> \
   --docker-password=<your-pword> \
   --docker-email=<your-email> \
   -n aqua
   ```

3. **Create platform-specific RBAC**

   * RBAC definitions can vary between platforms. Please choose the right aqua_sa.yaml for your platform

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/<<platform>>/aqua_sa.yaml
   ```

4. **Define the ConfigMap for the deployment.**

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/001_aqua_enforcer_configMaps.yaml
   ```
   
5. **Create secrets for the Enforcer deployment.**

   * The only mandatory secret is the **token** that authenticates the Enforcer over the Aqua Server:

   ```SHELL
   kubectl create secret generic enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
   ```

   * You can also manually modify the secret manifest file and use kubectl apply to create the token secret:
   ```SHELL
   https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/002_aqua_enforcer_secrets.yaml
   ```

6. **Create the Aqua Enforcer DaemonSet**

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/003_aqua_enforcer_daemonset.yaml
   ```
