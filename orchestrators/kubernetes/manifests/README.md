# Overview

The directories and files in this branch relate to enterprise-grade and advanced deployments of Aqua Enterprise on these Kubernetes platforms:
Kubernetes RAW, OpenShift, EKS, GKE, ICP, AKS, TKG, TKGI

Refer to the product documentation for deployment instructions: [Deployment on Kubernetes (most platforms)](https://docs.aquasec.com/v6.0/docs/deploy-k8s-most-platforms).

Aqua Enterprise deployment in a Kubernetes cluster begins with deployment of the Server components. These include the Server itself, its UI (console), the Aqua Gateway, and database (DB).

You can optionally deploy one or more of each of these components:

- Aqua Enforcers: one deployed per Kubernetes cluster as a DaemonSet
- Aqua KubeEnforcers: one deployed per Kubernetes cluster as an Admission Controller
- Aqua Scanners: can be deployed at multiple locations in your environment to optimize registry scanning performance and network utilization


# Contents

| Directory                                                    | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [aqua_csp_001_namespace](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_001_namespace) | Create the aqua namespace 
| [aqua_csp_002_RBAC](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC) | Create platform-specific RBAC |
| [aqua_csp_003_secrets](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_003_secrets) | Create secrets for the deployment |
| [aqua_csp_004_configMaps](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_004_configMaps) | Define the desired configurations for the deployment |
| [aqua_csp_005_storage](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_005_storage) | Configure the packaged database (optional) |
| [aqua_csp_006_server_deployment](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_006_server_deployment) | Deploy the Aqua Server components |
| [aqua_csp_007_networking](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_007_networking) | Advanced networking options for the Aqua Server components |
| [aqua_csp_008_scanner](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_008_scanner) | Deploy Aqua Scanners (optional) |
| [aqua_csp_009_enforcer](https://github.com/aquasecurity/deployments/tree/6.0/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer) | Deploy Aqua Enforcers and/or KubeEnforcers (optional) |

# Other Kubernetes deployments

Refer to the product documentation for deployment of Aqua Enterprise:
- Using Helm Charts: [Deployment on K8s using Helm Charts](https://docs.aquasec.com/v6.0/docs/kubernetes-with-helm)
- Other platforms: [Rancher / Kubernetes](https://docs.aquasec.com/v6.0/docs/rancher-kubernetes)
- Quick-start: To deploy Aqua Enterprise in your Kubernetes cluster quickly and easily, follow the instructions on [Quick-Start Guide for Kubernetes](https://docs.aquasec.com/v6.0/docs/quick-start-guide-for-kubernetes). The quick-start deployment is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test.
