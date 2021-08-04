## KubeEnforcer Starboard Overview

Starboard is an Aqua Security open-source tool that increases the effectiveness of Kubernetes security. Starboard is deployed by default, when you deploy KubeEnforcer.

When Starboard is deployed, it assesses workload compliance throughout the lifecycle of the workloads. This enables the KubeEnforcer to:
* Re-evaluate workload compliance during workload runtime, taking any workload and policy changes into account
* Reflect the results of compliance evaluation in the Aqua UI at all times, not only when workloads are created.

**Note:** When Starboard is not deployed, KubeEnforcer checks workloads for compliance only when the workloads are started.

To deploy KubeEnforcer with starboard:
- While performing the manual deployment, use the manifest yaml files specified in this directory.
- While deploying KubeEnforcer using Aquactl, add the relevant flag as specified in the section, [Automate KubeEnforcer deployment using Aquactl](#automate-kubeenforcer-deployment-using-aquactl).

Before you follow the deployment steps explained below, Aqua strongly recommends you refer the product documentation, [Deploy Aqua KubeEnforcer(s) with Starboard](https://docs.aquasec.com/docs/deploy-k8s-aqua-kubeenforcers#section-starboard-co-requisite).

## Specific OpenShift notes
The deployment commands shown below use the **kubectl** cli, however they can be easliy replaced with the **oc** cli commands, to work on all platforms including OpenShift.

## Prerequisites

- Your Aqua credentials: username and password
- Access to Aqua registry
- The target KubeEnforcer Group token
- Access to the target Aqua gateway
- A PEM-encoded CA bundle to validate the KubeEnforcer certificate
- A PEM-encoded SSL cert to configure the KubeEnforcer

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

Consider the following options for deploying the KubeEnforcer:

- **PEM-encoded CA bundle and SSL certs**: Use the *gen_ke_certs.sh* script to generate the required CA bundle, SSL certificates, and deploy the KubeEnforcer config. To generate CA bundle and SSL certificates manually, refer to the product documentation, [Configure mTLS](https://docs.aquasec.com/docs/configure-mtls).

- **Mutual Auth / Custom SSL certs**: Prepare the SSL cert for the domain you choose to configure for the Aqua Server. You should modify the manifest deployment files with the mounts to the SSL secrets files.

- **Gateway**: To connect with an external gateway in a multi-cluster deployment, update the **AQUA_GATEWAY_SECURE_ADDRESS** value with the Gateway endpoint address in the *001_kube_enforcer_config.yaml* file.

## Pre-deployment
You can skip any step in this section, if you have already performed.

**Step 1. Create a namespace (or an OpenShift  project) by name aqua (if not already done).**

```SHELL
$ kubectl create namespace aqua
```

**Step 2. Create a docker-registry secret (if not already done).**

```SHELL
$ kubectl create secret docker-registry aqua-registry \
--docker-server=registry.aquasec.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
--docker-email=<your-email> \
-n aqua
```

## Deploy KubeEnforcer using manifests

**Step 1. Deploy the KubeEnforcer config.**
   
* **Option A (Automatic)**: Generate CA bundle (rootCA.crt), SSL certs (aqua_ke.key, aqua_ke.crt), and deploy the KubeEnforcer config.

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/kube_enforcer/kubenetes_and_openshift/manifests/kube_enforcer_starboard/gen_ke_certs.sh
```
        
* **Option B (Manual)**: Perform the steps mentioned in the [Deploy the KubeEnforcer Config manually](#deploy-the-kubeenforcer-config-manually) section.

**Step 2.  Create token and SSL secrets.**

* Create the token secret.

```shell
$ kubectl create secret generic aqua-kube-enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
```

* Create the SSL cert secret using SSL certificates.
    
```shell
$ kubectl create secret generic kube-enforcer-ssl --from-file aqua_ke.key --from-file aqua_ke.crt -n aqua
```

                                        (or)

* Download, edit, and apply the secrets manifest file to create the token and SSL cert secrets.

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/kube_enforcer/kubenetes_and_openshift/manifests/kube_enforcer_starboard/002_kube_enforcer_secrets.yaml
```    

**Step 3. Deploy KubeEnforcer with Starboard.**

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/enforcers/kube_enforcer/kubenetes_and_openshift/manifests/kube_enforcer_starboard/003_kube_enforcer_deploy.yaml
```

### Deploy the KubeEnforcer Config manually

Step 1. Download the manifest yaml file, *001_kube_enforcer_config.yaml*.

Step 2. Generate a CA bundle and SSL certs.

Step 3. Modify the config yaml file to include the PEM-encoded CA bundle (caBundle).

Step 4. Apply the modified manifest file config.

```shell
$ kubectl apply -f 001_kube_enforcer_config.yaml
```

## Automate KubeEnforcer deployment using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy KubeEnforcer using manifests](#deploy-kubeenforcer-using-manifests). Command shown in this section creates (downloads) manifests (yaml) files quickly and prepares them for the KubeEnforcer deployment. To deploy Aqua KubeEnforcer with starboard, include the **--starboard** flag in the aquactl download command syntax, in addition to the required flags for KubeEnforcer.

### Command Syntax

```SHELL
aquactl download kube-enforcer [flags]
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

#### Configuration of KubeEnforcer with Starboard

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --starboard | Deploy Starboard with the KubeEnforcer|
| --gateway-url (string) | Aqua Gateway URL (IP, DNS, or service name) and port, it defaults to **aqua-gateway:8443**|
| --token (string) | Deployment token for the KubeEnforcer group, it does not have a default value|
| --ke-no-ssl (Boolean) | If specified as **true**, the SSL cert for the KubeEnforcer will not be generated. It defaults to **false**|

The **--gateway-url** flag identifies an existing Aqua Gateway used to connect the KubeEnforcer. This flag is not used to configure a new Gateway, as in *aquactl download all* or *aquactl download server*.

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
aquactl download kube-enforcer --starboard --platform gke --version 6.5 \
--token <KUBE_ENFORCER_GROUP_TOKEN> \
--gateway-url 221.252.82.95:8443 --output-dir aqua-kube-enforcer-files
```