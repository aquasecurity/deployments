## Deploying AQUA CSP

Aqua deployment is composed of three main components - 

- Aqua Server - The control plane and console.
- Aqua Enforcer - The policy enforcement agents. Aqua has a few types of Enforcers for different use-cases and platforms. 
- Aqua Scanner - The container image scanner to increasing scanning throughput. Can be implemented at multiple locations in the pipeline to optimize performance and network consumption. 

The above manifests file can be used to deploy Aqua CSP

| Directory                                                    | Description                                                  |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [aqua_csp_001_namespace](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_001_namespace) | Create aqua namespace                                        |
| [aqua_csp_002_RBAC](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC) | Contains subdirectories with K8s platform names. Can be used to create K8s platform specific role based access controls |
| [aqua_csp_003_secrets](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_003_secrets) | Create database password secret. Currently set to "password". Please change the secret if required |
| [aqua_csp_004_configMaps](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_004_configMaps)^ | Create database (packaged) and server configMaps*            |
| [aqua_csp_005_storage](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_005_storage)^ | Create PVC to store packaged database data                   |
| [aqua_csp_006_server_deployment](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_006_server_deployment) | Contains two different manifests to deploy Aqua CSP. <br />One with packaged DB + server deployment and other with just server deployment. |
| [aqua_csp_007_networking](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_007_networking) | Contains subdirectories with ingress names. Can be used to create ingress for advanced deployment scenarios. |
| [aqua_csp_008_scanner](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_008_scanner) | Create Aqua Scanner deployment.                              |
| [aqua_csp_009_enforcer](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer) | Create Aqua Enforcer Daemonset deployment or Aqua KubeEnforcer deployment (Only 1 for entire cluster) |

*Please read AQUA ENVIRONMENT AND CONFIGURATION topic in docs site.

^Please skip creating database configMap and PVC if you intend to use managed database. Also update the server configMap with managed DB endpoint URL.