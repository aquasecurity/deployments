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

It is strongly recommended to change the database password (*aqua-db*) before you deploy Aqua Enterprise. Different secrets can be used to provision licenses, passwords, and security keys.

5. Set the Server configuration: Configure the server using ConfigMap yaml as explained below:

You can use the default ConfigMap yaml file offered by Aqua to set the server configuration. Run the following command to set the default server configuration:

 ```SHELL
  $ kubectl apply -f https://raw.githubusercontent.com/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_004_configMaps/aqua_server.yaml
   ```

You can change the deafult server configuration by editing the ConfigMap yaml file for several reasons, such as:
* to use an external database instead of the Aqua packaged database
* to set tokens for Enforcer groups
* to configure Active-Active Server Mode, so on.

For more information on the description of all server configuration options, refer to the product documentation, [Aqua Server ConfigMap](https://docs.aquasec.com/docs/deploy-k8s-configmaps-and-secrets#section-aqua-server-config-map).

Perfrom the following steps to change the default server configuration options:

   a. Download the *aqua_server.yaml* ConfigMap.
   b. Edit the file as required.
   c. Run the following command (kubectl apply), using the edited copy:

 ```SHELL
  $ kubectl apply -f aqua_server.yaml
   ```

6. Configure the packaged database *(optional)*

Perform this step only if you want to use Aqua’s packaged PostgreSQL DB container.

By default, the Aqua packaged DB is configured as small (**S**). If you want to use a different value, change the value of environment size for the AQUA_ENV_SIZE key in the Aqua packaged database ConfigMap yaml and run commands with the edited yaml file. For more information on this, refer to the product documentation, [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide) and [Aqua Packaged DB Operational Guide](https://docs.aquasec.com/docs/aqua-packaged-db-operational-guide#section-configure-the-db-environment-size-recommended).

Run the following commands to configure the packaged database:

 ```SHELL
  $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_004_configMaps/aqua_db.yaml

  $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_005_storage/aqua_db_pvc.yaml
   ```

7. Configure HTTPS for the Aqua Server *(optional)*

If you want to configure HTTPS for the Aqua server, perform steps mentioned in this product document, [Configure HTTPS for the Aqua Server](https://docs.aquasec.com/docs/deploy-k8s-configure-https-for-the-aqua-server).

8. Deploy the Aqua components

If you use Aqua packaged DB, run the following command to deploy Aqua server:

```SHELL
  $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_006_server_deployment/aqua_server_deployment_packaged_db.yaml
   ```

If you use external managed DB, run the following command to deploy Aqua server:

```SHELL
  $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_006_server_deployment/aqua_server_deployment_managed_db.yaml
   ```

9. Expose the Server and Gateway services

This step exposes the Aqua Server (Console) and the Gateways to external communications. This step covers three common use cases for exposing the IP of the respective services.

   a. Option A (default): Kubernetes LoadBalancer service type
   
   The default option uses a single Gateway service. It can support production environments with up to 500 hosts. Both the Server and the Gateway are exposed through a LoadBalancer Service.

   Run the following command to set up the LoadBalancer service:

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_007_networking/loadbalancer/aqua_server_gateway_service-lb.yaml
   ```

   b. Option B: Use an Ingress (Envoy) to route traffic to your Gateway farm

   In large environments (more than 500 hosts), you should scale the number of Gateways and expose them through an Ingress controller that supports the gRPC and HTTP2 protocols. The deployment script for this configuration uses Envoy as the Ingress for the Gateway farm. Perform the following steps for this configuration:

   1. Generate certificates for the Envoy service. You should prepare keys and certs for the secure communication with Envoy, and load them as secrets to the cluster. You can bring your own keys or follow the instructions in the product documentation, [Configure mTLS](https://docs.aquasec.com/docs/configure-mtls).
   
   2. Scale the number of Gateways by running the following command:

   ```SHELL
   $ kubectl -n aqua scale --replicas=<N> deployment.apps/aqua-gateway
   ```

   3. Load the TLS keys and certs as secrets by running the following command:

   ```SHELL
   $ kubectl create secret tls aqua-lb-certs --key <<tls-key.key>> --cert <<tls.crt>> -n aqua
   ```      

   4. Deploy Envoy

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_007_networking/envoy/001_server_gateway_service-envoy.yaml

   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_007_networking/envoy/003_envoy-configmap.yaml

   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_007_networking/envoy/004_envoy-deployment.yaml
   ```   

   c. Option C: Use an OpenShift route

   If you deploy Aqua Enterprise in an OpenShift environment, you can expose both the console and the Gateway with a route by running the following commands:

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_007_networking/openshift_route/aqua-gateway-route.yaml

   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/1_server/manifests/aqua_csp_007_networking/openshift_route/aqua-web-route.yaml
   ```

## Deploy Aqua server using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Aqua server using Manifests](#deploy-aqua-server-using-manifests). Command shown in this section creates (downloads) manifests (yaml files) that can be used to deploy the Aqua Enterprise Server, Database, and Gateway components on a Kubernetes cluster.

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
(string) (mandatory flag) | Major version of Aqua Enterprise to deploy. For example: **6.2** |
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

To get help on this function, enter the following command:

```SHELL
aquactl download server -h
```

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.