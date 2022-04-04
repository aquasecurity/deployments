# Quick-Start Deployment of Aqua Enterprise using Aquactl
Aquactl is the command-line utility to automate the quick-start deployment of Aqua Enterprise. Command shown in this section creates (downloads) manifests (yaml files) quickly and prepares them for the Aqua Enterprise deployment.

## Command Syntax

```SHELL
aquactl download all [flags]
```

## Flags
You can pass the following deployment options through flags, as required.

You can pass non-mandatory flags only if the configuration is absolutely required. Without passing these flags, Aqua Enterprise will be deployed on a single cluster with default configuration for the purpose of non-production usage.

### Aquactl operation

Flag and parameter type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| -p or --platform, (string) (mandatory flag) | Orchestration platform to deploy Aqua Enterprise on. you should pass one of the following as required: **kubernetes, aks, eks, gke, iks, openshift, tkgi, rancher**    |
| * -v or --version
(string) (mandatory flag) | Major version of Aqua Enterprise to deploy. For example: **2022.4** |
| -r or --registry (string) | Docker registry containing the Aqua Enterprise product images, it defaults to **registry.aquasec.com** |
| --pull-policy (string) | The Docker image pull policy that should be used in deployment for the Aqua product images, it defaults to **IfNotPresent** |
| --service-account (string) | Kubernetes service account name, it defaults to **aqua-sa** |
| -n, --namespace (string) | Kubernetes namespace name, it defaults to **aqua** |
| --output-dir (string) | Output directory for the manifests (YAML files), it defaults to **aqua-deploy**, the directory aquactl was launched in |
| --add-registry-secret (string) | Create Registry secret for *aqua-registry* |
| --tls-verify (common name validation) | Check that the peer's certificate is chained up to a trusted certificate authority and
that the peer's host-name matches its certificate |

### Aqua database configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --external-db (Boolean) | Include this flag if you want to use external managed database, instead of the Aqua packaged database, it defaults to **false**|
| --internal-db-size (string) | Size of the Aqua packaged database, it must be **S** (default), **M**, or **L**|
| --external-db-host (string) | External database IP or DNS, it does not have a default value|
| --external-db-port (int) | External database port, it defaults to **5432** |
| --external-db-username (string) | Username of the external database, it does not have a default value |
| --external-db-password (string)| Password for the user of the external database, it does not have a default value |

### Aqua Gateway configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --ingress-gw (string) | Route for Aqua Gateway connectivity, example: **envoy**, it does not have a default value|

### Aqua Enforcer and KubeEnforcer configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --batch-install-ke-token (string) | Aqua KubeEnforcer group token, it defaults to **ke-token** |
| --batch-install-token (string) | Aqua Enforcer group token, it defaults to **enforcer-token** |
| --exclude-daemon-set | Do not download Aqua Enforcer manifest files |
| --exclude-ke | Do not download KubeEnforcer manifest files |
| --ke-advanced-configuration | Set this to use advanced configuration for the KubeEnforcer |
| --ke-no-ssl | Set this to bypass generation of the SSL cert for the KubeEnforcer |

### Usage example 

```SHELL
aquactl download all --platform eks --version 2022.4
```

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.