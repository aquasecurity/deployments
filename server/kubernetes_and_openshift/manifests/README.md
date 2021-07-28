## Overview
Aqua product deployment in a Kubernetes cluster begins with deployment of the server, by using multiple manifest yaml files. This component includes the server itself, its UI (console), the Aqua Gateway, and database (DB). You can optionally deploy one or multiple other Aqua components later, as required.

This repository shows all the directories and manifest yaml files required to deploy the Aqua server component on the following Kubernetes platforms:
* Kubernetes 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Aqua strongly recommends you refer the product documentation, [Deploy Server Components](https://docs.aquasec.com/docs/deploy-k8s-server-components).
## Prerequisites
* Your Aqua credentials: username and password
* Your Aqua Enterprise License Token
* Access to the target Kubernetes cluster with RBAC authorization. The cluster should have a default storage and load-balancer controller. If your cluster does not have these, you should edit the YAML files to configure them

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).
## Considerations
Before you start deploying Aqua server, you can consider the following options.
### Packaged or external managed database
Aqua Enterprise offers packaged PostgreSQL database container. However, for large environments and enterprise companies with advanced requirements, Aqua recommends to use an external managed PostgreSQL database.
### HTTPS for the Aqua Server
To configure an HTTPS (secure) channel, refer to [Configure HTTPS for the Aqua Server](https://docs.aquasec.com/docs/deploy-k8s-configure-https-for-the-aqua-server).
### Active-active Server mode
Configure Active-active Server mode for high availability of Aqua Enterprise. For more information, refer to the product documentation, [Deploy Aqua in Active-Active Server Mode](https://docs.aquasec.com/docs/deploy-k8s-aqua-in-active-active-server-mode).
### mTLS
To configure mTLS (mutual TLS) instead of the default TLS, refer to the product documentation, [Configure mTLS](https://docs.aquasec.com/docs/configure-mtls).
### Run the Server behind a reverse proxy
The Aqua Server container (deployed from the image registry.aquasec.com/console) can be run behind a reverse proxy server such as Apache, NGINX, or HAProxy. For more information, refer to the product documentation, [Run the Server behind a reverse proxy](https://docs.aquasec.com/docs/aqua-server-recommendations#section-run-the-server-behind-a-reverse-proxy).
### Ingress resource
For large environments with more than 500 nodes, you should define a gRPC-supported Ingress to act as a load balancer for multiple Aqua Gateways. For more information, refer to the product documentation, [Advanced Deployment Architecture](https://docs.aquasec.com/docs/advanced-deployment-architecture).
## Supported platforms
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
## Deploy Aqua server using Manifests
Perform the following steps to deploy Aqua server manually:

1. Create a namespace (or an OpenShift  project) by name **aqua**.
   
2. Create a docker-registry secret to aqua-registry to download the images.
   
3. Create a service account and RBAC settings by creating or applying the relevant yaml file from the directory, *aqua_csp_002_RBAC/< PLATFORM >/aqua_sa.yaml*. You should select the required yaml file depends on your platform. Aqua supports many platforms, as mentioned in the [Supported Platforms](#supported-platforms) section.
   
4. Create the deployment secrets manually or download, edit, and apply the secrets yaml file from *aqua_csp_003_secrets/aqua_secrets.yaml*. It is strongly recommended to change the database password (aqua-db) before you deploy Aqua Enterprise. Different secrets can be used to provision licenses, passwords, and security keys.

5. Download, edit, and run the deployment configMaps yaml file from *aqua_csp_004_configMaps/aqua_server.yaml*. The config-map is ready for most delployments, however you might need to edit it to change the default server configuration options, such as:
   * to use an external database instead of the Aqua packaged database
   * to set tokens for Enforcer groups
   * to configure Active-Active Server Mode, so on.

6. If you want to use Aqua’s packaged PostgreSQL DB container, configure the packaged database using the db yaml files from *aqua_csp_004_configMaps/aqua_db.yaml* and *aqua_csp_005_storage/aqua_db_pvc.yaml*. For more information on this, refer to the product documentation, [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide) and [Aqua Packaged DB Operational Guide](https://docs.aquasec.com/docs/aqua-packaged-db-operational-guide#section-configure-the-db-environment-size-recommended).

7. *(optional)* Configure HTTPS for the Aqua Server, by referring the product documentation, [Configure HTTPS for the Aqua Server](https://docs.aquasec.com/docs/deploy-k8s-configure-https-for-the-aqua-server).

8. Deploy the Aqua components as explained below:
   * For Aqua packaged DB, use the yaml file from *aqua_csp_006_server_deployment/aqua_server_deployment_packaged_db.yaml*
   * For external managed DB, use yaml file from *aqua_csp_006_server_deployment/aqua_server_deployment_managed_db.yaml*

9. Expose the Server and Gateway services as explained below:
   * Option A (default): For Kubernetes LoadBalancer service type, use the yaml file from *aqua_csp_007_networking/loadbalancer/aqua_server_gateway_service-lb.yaml*

   * Option B: Use an Ingress (Envoy) to route traffic to your Gateway farm. Perform the following steps to for this configuration:

      a. Generate certificates for the Envoy service using yaml file, *aqua_csp_007_networking/envoy/002_envoy-secrets.yaml*.
   
      b. Scale the number of Gateways by running the following command:

      ```SHELL
      $ kubectl -n aqua scale --replicas=<N> deployment.apps/aqua-gateway
      ```

      c. Load the TLS keys and certs as secrets by running the following command:

      ```SHELL
      $ kubectl create secret tls aqua-lb-certs --key <<tls-key.key>> --cert <<tls.crt>> -n aqua
      ```      

      d. Deploy Envoy using the following yaml files from the directory, *aqua_csp_007_networking/envoy*:
      - *001_server_gateway_service-envoy.yaml*
      - *003_envoy-configmap.yaml*
      - *004_envoy-deployment.yaml*

   * Option C: Use an OpenShift route. To deploy Aqua Enterprise in an OpenShift environment, expose both the console and the Gateway with a route by running the commands using the following yaml files from the directory, *aqua_csp_007_networking/openshift_route*:
      - *aqua-gateway-route.yaml*
      - *aqua-web-route.yaml*

### Specific OpenShift notes
The deployment commands shown above use the **kubectl** cli, however they can be easliy replaced with the **oc** or **podman** cli commands, to work on all platofrms including OpenShift.

## Automate Server deployment using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Aqua server using Manifests](#deploy-aqua-server-using-manifests). Command shown in this section creates (downloads) manifests (yaml files) quickly and prepares them for the Aqua Server deployment.

### Command Syntax

```SHELL
aquactl download server [flags]
```

### Flags
You should pass the following deployment options through flags, as required.

#### Aquactl operation

Flag and parameter type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| -p or --platform, (string) (mandatory flag) | Orchestration platform to deploy Aqua Enterprise on. you should pass one of the following as required: **kubernetes, aks, eks, gke, icp, openshift, tkg, tkgi**    |
| * -v or --version
(string) (mandatory flag) | Major version of Aqua Enterprise to deploy. For example: **6.5** |
| -r or --registry (string) | Docker registry containing the Aqua Enterprise product images, it defaults to **registry.aquasec.com** |
| --pull-policy (string) | The Docker image pull policy that should be used in deployment for the Aqua product images, it defaults to **IfNotPresent** |
| --service-account (string) | Kubernetes service account name, it defaults to **aqua-sa** |
| -n, --namespace (string) | Kubernetes namespace name, it defaults to **aqua** |
| --output-dir (string) | Output directory for the manifests (YAML files), it defaults to **aqua-deploy**, the directory aquactl was launched in |

#### Aqua database configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --external-db (Boolean) | Include this flag if you want to use external managed database, instead of the Aqua packaged database, it defaults to **false**|
| --internal-db-size (string) | Size of the Aqua packaged database, it must be **S** (default), **M**, or **L**|
| --external-db-host (string) | External database IP or DNS, it does not have a default value|
| --external-db-port (int) | External database port, it defaults to **5432** |
| --external-db-username (string) | Username of the external database, it does not have a default value |
| --external-db-password (string)| Password for the user of the external database, it does not have a default value |

#### Aqua Gateway configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --ingress-gw (string) | Route for Aqua Gateway connectivity, example: **envoy**, it does not have a default value|

To get help on the Aquactl function, enter the following command:

```SHELL
aquactl download server -h
```

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
aquactl download server --platform eks --version 6.5
```