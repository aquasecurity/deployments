## Overview
This repository shows all the directories and manifest yaml files required to deploy the Aqua server component on the following Kubernetes platforms:
* Kubernetes (native) 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Aqua product deployment in a Kubernetes cluster begins with deployment of the server, by using multiple manifest yaml files. This component includes the server itself, its UI (console), the Aqua Gateway, and database (DB). You can optionally deploy one or multiple other Aqua components later, as required.

For detailed step-by-step instructions to deploy Aqua server component by using these yaml files, refer to the product documentation, [Deploy Server Components](https://docs.aquasec.com/docs/deploy-k8s-server-components).

## Prerequisites for manifest deployment

Make sure that you have the following available, before you start deploying server using manifests:
* Your Aqua credentials: username and password
* Your Aqua Enterprise License Token
* Access to the target Kubernetes cluster through kubectl with RBAC authorization to deploy applications. The cluster should have a default storage and load-balancer controller. If these resources are not available on the cluster, you might need to change the YAML files to accommodate your specific configurations.

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Deploy Aqua server using Manifests

Multiple manifest yaml files are required to deploy Aqua server component, manually. These manifest files are stored in the following directories.

| Directory                                                    | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [aqua_self-hosted_001_namespace](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_001_namespace) | Create the aqua namespace 
| [aqua_self-hosted_002_RBAC](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_002_RBAC) | Create platform-specific RBAC |
| [aqua_self-hosted_003_secrets](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_003_secrets) | Create secrets for the deployment |
| [aqua_self-hosted_004_configMaps](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_004_configMaps) | Define the desired configurations for the deployment |
| [aqua_self-hosted_005_storage](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_005_storage) | Configure the packaged database (optional) |
| [aqua_self-hosted_006_server_deployment](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_006_server_deployment) | Deploy the Aqua Server components |
| [aqua_self-hosted_007_networking](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server/manifests/aqua_csp_007_networking) | Advanced networking options for the Aqua Server components |

For detailed step-by-step instructions to deploy Aqua server component by using these yaml files, refer to the product documentation, [Deploy Server Components](https://docs.aquasec.com/docs/deploy-k8s-server-components).
## Deploy Aqua server using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the previous section, Manifests. This utility creates (downloads) manifests that are customized to your specifications. For more information on the usage of Aquactl to deploy Aqua server, refer to the product documentation, [Aquactl: Download Server Component Manifests](https://docs.aquasec.com/docs/aquactl-download-manifests-server-components).