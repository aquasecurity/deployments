# Deploy Aqua Server using manifests

## Overview
Aqua Enterprise self-hosted product deployment in a Kubernetes cluster begins with deployment of the server, by using multiple manifest yaml files. Server includes the following components:

Console (Aqua UI)
Gateway
Database (DB). 

You can optionally deploy one or multiple other Aqua components later, as required.

This repository shows all the directories and manifest yaml files required to deploy the Aqua server component on the following Kubernetes platforms:
* Kubernetes 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Aqua strongly recommends you refer the product documentation, [Deploy Server Components](https://docs.aquasec.com/v6.5/docs/deploy-k8s-server-components).

## Specific OpenShift notes
The deployment commands shown below use the **kubectl** cli, however they can be easliy replaced with the **oc** cli commands, to work on all platforms including OpenShift.

## Prerequisites
* Your Aqua credentials: username and password
* Your Aqua Enterprise License Token
* Access to the target Kubernetes cluster with RBAC authorization
* The cluster should have a default storage and load-balancer controller. If your cluster does not have these, you should edit the YAML files to configure them as required.

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/v6.5/docs/sizing-guide).
## Considerations
Before you start deploying Aqua server, you may perform the following configurations, as required.
### Packaged or external managed database
Aqua Enterprise offers packaged PostgreSQL database container. For large environments and enterprise companies with advanced requirements, Aqua recommends to use an external managed PostgreSQL database by following the deployment steps below.
### HTTPS for the Aqua Server
To configure an HTTPS (secure) channel, refer to [Configure HTTPS for the Aqua Server](https://docs.aquasec.com/v6.5/docs/deploy-k8s-configure-https-for-the-aqua-server).
### Active-active Server mode
To configure Active-active Server mode for high availability of Aqua Enterprise, refer to the product documentation, [Deploy Aqua in Active-Active Server Mode](https://docs.aquasec.com/v6.5/docs/deploy-k8s-aqua-in-active-active-server-mode).
### mTLS
To configure mTLS (mutual TLS) instead of the default TLS between server and other Aqua components, refer to the product documentation, [Configure mTLS](https://docs.aquasec.com/v6.5/docs/configure-mtls).
### Run the Server behind a reverse proxy
The Aqua Server container (deployed from the image registry.aquasec.com/console) can be run behind a reverse proxy server such as Apache, NGINX, or HAProxy. To configure this, refer to the product documentation, [Run the Server behind a reverse proxy](https://docs.aquasec.com/v6.5/docs/aqua-server-recommendations#section-run-the-server-behind-a-reverse-proxy).
### Ingress resource
For large environments with more than 500 nodes, you should define a gRPC-supported Ingress to act as a load balancer for multiple Aqua Gateways. To configure this, refer to the product documentation, [Advanced Deployment Architecture](https://docs.aquasec.com/v6.5/docs/advanced-deployment-architecture).
## Supported platforms
| < PLATFORM >              | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| aks | Microsoft Azure Kubernetes Service (AKS)    |
| eks | Amazon Elastic Kubernetes Service (EKS) |
| gke | Google Kubernetes Engine (GKE) |
| ibm | IBM Cloud Private (ICP) |
| k3s | fully CNCF certified Kubernetes |
| native_k8s | Kubernetes |
| openshift | OpenShift (Red Hat) |
| rancher | Rancher / Kubernetes |
| tkg | VMware Tanzu Kubernetes Grid (TKG) |
| tkgi | VMware Tanzu Kubernetes Grid Integrated Edition (TKGI) |

## Pre-deployment
You can skip any of the steps if you have already performed.

**Step 1. Create a namespace (or an OpenShift  project) by name aqua (if not already done).**

   ```SHELL
   kubectl create namespace aqua
   ```

**Step 2. Create a docker-registry secret (if not already done).**

   ```SHELL
   kubectl create secret docker-registry aqua-registry \
--docker-server=registry.aquasec.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email> \
-n aqua
   ```

**Step 3. Create a service account and RBAC for your deployment platform (if not already done).** Replace the platform name from [Supported platforms](#supported-platforms).

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_002_RBAC/< PLATFORM >/aqua_sa.yaml
   ```

## Deploy Aqua server using manifests
   
**Step 1. Create the secrets manually or download, edit, and apply the secrets.** It is strongly recommended to change the database password (aqua-db).

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_003_secrets/aqua_secrets.yaml
   ```

**Step 2. Deploy directly or download, edit, and run the deployment configMaps**

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_004_configMaps/aqua_server.yaml
   ```

**Step 3. *(Optional)* Configure the packaged database** (If you use Aqua’s packaged PostgreSQL DB container). 

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_004_configMaps/aqua_db.yaml

   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_005_storage/aqua_db_pvc.yaml
   ```

For large and complex deployments, refer to the product documentation, [Sizing Guide](https://docs.aquasec.com/v6.5/docs/sizing-guide) and [Aqua Packaged DB Operational Guide](https://docs.aquasec.com/v6.5/docs/aqua-packaged-db-operational-guide#section-configure-the-db-environment-size-recommended).

**Step 4. Deploy Aqua server.**

- With Aqua’s packaged DB

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_006_server_deployment/aqua_server_deployment_packaged_db.yaml
   ```

- With external managed DB

   ```SHELL
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_006_server_deployment/aqua_server_deployment_managed_db.yaml
   ```

## Expose the Server and Gateway services

You can expose Server and Gateway through one of the three following use cases:

- [Kubernetes LoadBalancer service type](#kubernetes-loadbalancer-service-type-default)
- [Use an Ingress (Envoy) to route traffic to your Gateway farm](#use-an-ingress-envoy)
- [Use an OpenShift route](#use-an-openshift-route)

### Kubernetes LoadBalancer service type

It is a default option. It uses single Gateway service and supports upto 500 hosts. 

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_007_networking/loadbalancer/aqua_server_gateway_service-lb.yaml
```      

### Use an Ingress (Envoy)

**Step 1. Generate certificates for the Envoy service.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_007_networking/envoy/002_envoy-secrets.yaml
```        
   
**Step 2. Scale the number of Gateways.** Replace *N* with the number of Gateways required.

```SHELL
kubectl -n aqua scale --replicas=<N> deployment.apps/aqua-gateway
```

**Step 3. Load the TLS keys and certs as secrets.**

```SHELL
kubectl create secret tls aqua-lb-certs --key <<tls-key.key>> --cert <<tls.crt>> -n aqua
```      

**Step 4. Deploy Envoy service.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_007_networking/envoy/001_server_gateway_service-envoy.yaml
```  

**Step 5. Deploy Envoy Configmap.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_007_networking/envoy/003_envoy-configmap.yaml
``` 

**Step 6. Deploy Envoy.**

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_007_networking/envoy/004_envoy-deployment.yaml
```

### Use an OpenShift route

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_007_networking/openshift_route/aqua-gateway-route.yaml

kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/server/kubernetes_and_openshift/manifests/aqua_csp_007_networking/openshift_route/aqua-web-route.yaml
```

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

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
aquactl download server --platform eks --version 6.5
```