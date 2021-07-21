## Overview
This repository shows all the directories and manifest yaml files required to deploy the Aqua server component on the following Kubernetes platforms:
* Kubernetes 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Aqua product deployment in a Kubernetes cluster begins with deployment of the server, by using multiple manifest yaml files. This component includes the server itself, its UI (console), the Aqua Gateway, and database (DB). You can optionally deploy one or multiple other Aqua components later, as required.

For detailed step-by-step instructions to deploy Aqua server component by using these yaml files, refer to the product documentation, [Deploy Server Components](https://docs.aquasec.com/docs/deploy-k8s-server-components).

## Prerequisites

Make sure that you have the following available, before you start deploying server using manifests:
* Your Aqua credentials: username and password
* Your Aqua Enterprise License Token
* Access to the target Kubernetes cluster through kubectl with RBAC authorization to deploy applications. The cluster should have a default storage and load-balancer controller. If these resources are not available on the cluster, you might need to change the YAML files to accommodate your specific configurations.

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

Before you start deploying Aqua server, you can consider the following options.

### Packaged or external managed database

Aqua Enterprise offers packaged PostgreSQL database container.However, for large environments and enterprise companies with advanced requirements, Aqua recommends that you use an external managed PostgreSQL database. For more information, refer to the product documentation, [Deploy Server Components](https://docs.aquasec.com/docs/deploy-k8s-server-components#section-packaged-or-external-managed-database).

### HTTPS for the Aqua Server

By default, deploying Aqua Enterprise configures an HTTP channel between the Aqua Server (console) and the web browser (UI). To configure an HTTPS (secure) channel, refer to [Configure HTTPS for the Aqua Server](https://docs.aquasec.com/docs/deploy-k8s-configure-https-for-the-aqua-server).

### Active-active Server mode

High availability is managed by the Kubernetes platform for all Aqua Enterprise containers. If you want to configure Active-active Server mode for high availability of Aqua Enterprise, refer to the product documentation, [Deploy Aqua in Active-Active Server Mode](https://docs.aquasec.com/docs/deploy-k8s-aqua-in-active-active-server-mode).

### mTLS

By default, deploying Aqua Enterprise configures TLS-based encrypted communication, using self-signed certificates, among the Aqua Server, Gateway, Aqua Enforcer, and KubeEnforcer. To configure mTLS (mutual TLS) instead of the default TLS, refer to the product documentation, [Configure mTLS](https://docs.aquasec.com/docs/configure-mtls).

### Run the Server behind a reverse proxy

The Aqua Server container (deployed from the image registry.aquasec.com/console) can be run behind a reverse proxy server such as Apache, NGINX, or HAProxy. For more information, refer to the product documentation, [Run the Server behind a reverse proxy](https://docs.aquasec.com/docs/aqua-server-recommendations#section-run-the-server-behind-a-reverse-proxy).

### Ingress resource

For large environments with more than 500 nodes, you should define a gRPC-supported Ingress to act as a load balancer for multiple Aqua Gateways. For more information, refer to the product documentation, [Advanced Deployment Architecture](https://docs.aquasec.com/docs/advanced-deployment-architecture).

## Deploy Aqua server using Manifests

Perform the following steps to deploy Aqua server manually:

1. Create a Namespace

   ```SHELL
   $ kubectl create namespace aqua
   ```

2. Create the docker-registry secret

   ```shell
   $ kubectl create secret docker-registry aqua-registry \
   --docker-server=registry.aquasec.com \
   --docker-username=<your-name> \
   --docker-password=<your-password> \
   --docker-email=<your-email> -n aqua
   ```

3. Create platform-specific RBAC

Run the following command to create a service account for the required platform.

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_002_RBAC/<PLATFORM>/aqua_sa.yaml
   ```
You must substitute *< PLATFORM >* with the appropriate value from the following table:

| < PLATFORM >              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| aks | Microsoft Azure Kubernetes Service (AKS)    |
| eks | Amazon Elastic Kubernetes Service (EKS) |
| gke | Google Kubernetes Engine (GKE) |
| ibm | IBM Cloud Private (ICP) |
| native_k8s | Kubernetes |
| openshift | OpenShift (Red Hat) |
| rancher | Rancher / Kubernetes |
| tkg | VMware Tanzu Kubernetes Grid (TKG) |
| tkgi | VMware Tanzu Kubernetes Grid Integrated Edition (TKGI) |

4. Create secrets for the deployment

   ```SHELL
  $ kubectl apply -f https://raw.githubusercontent.com/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_003_secrets/aqua_secrets.yaml
   ```

It is strongly recommended to change the database password (*aqua-db*) before you deploy Aqua Enterprise. Other secrets can be used to provision licenses, passwords, and security keys.

For detailed step-by-step instructions to deploy Aqua server component by using these yaml files, refer to the product documentation, [Deploy Server Components](https://docs.aquasec.com/docs/deploy-k8s-server-components).
## Deploy Aqua server using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the previous section, Manifests. This utility creates (downloads) manifests that are customized to your specifications. For more information on the usage of Aquactl to deploy Aqua server, refer to the product documentation, [Aquactl: Download Server Component Manifests](https://docs.aquasec.com/docs/aquactl-download-manifests-server-components).