## Deploying AQUA CSP

Aqua deployment is composed of three main components - 

- Aqua Server - The control plane and console.
- Aqua Enforcer - The policy enforcement agents. Aqua has a few types of Enforcers for different use-cases and platforms. 
- Aqua Scanner - The container image scanner to increasing scanning throughput. Can be implemented at multiple locations in the pipeline to optimize performance and network consumption. 

The above manifests file can be used to deploy Aqua CSP

| Directory                                                    | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [aqua_csp_001_namespace](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_001_namespace) | Create aqua namespace                                        |
| [aqua_csp_002_RBAC](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC) | Create aqua's service-account and its cluster-roles according to the K8s platform |
| [aqua_csp_003_secrets](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_003_secrets) | Define secrets for Aqua's deployment |
| [aqua_csp_004_configMaps](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_004_configMaps) | Define the config-maps for Aqua's deployment            |
| [aqua_csp_005_storage](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_005_storage) | Create PVC for the packaged database                   |
| [aqua_csp_006_server_deployment](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_006_server_deployment) | Deploy the Aqua's server |
| [aqua_csp_007_networking](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_007_networking) | Advanced networking options for Aqua's server |
| [aqua_csp_008_scanner](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_008_scanner) | Deploy the Aqua's Scanner |
| [aqua_csp_009_enforcer](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer) | Deploy the Aqua's Enforcers |

Refer to Aqua's formal documentations for the complete deployment manual 