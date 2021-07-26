## Aqua Enforcer Overview

The Aqua Enforcer, running as a DaemonSet deployment, provides runtime security for your Kubernetes workloads by blocking unauthorized deployments, monitoring and restricting runtime activities, and generating audit events for your review. For more information, refer the product documentation, [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview#section-aqua-enforcers) and [Aqua Enforcer](https://docs.aquasec.com/docs/aqua-enforcer).

This repository shows all the directories and manifest yaml files required to deploy Aqua Enforcer on the following Kubernetes platforms:
* Kubernetes 
* OpenShift 
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Aqua strongly recommends you refer the product documentation, [Deploy Aqua Enforcer(s)](https://docs.aquasec.com/docs/deploy-k8s-aqua-enforcers) for detailed information.

## Prerequisites for manifest deployment

- Your Aqua credentials: username and password
- Access to Aqua registry to pull images
- The target Enforcer Group token 
- Access to the target Aqua gateway 

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

Consider the following options for deploying the Aqua Enforcer DaemonSet:

- Mutual Auth / Custom SSL certs

  - Prepare the SSL cert for your Aqua Server domain to use your CA authority. You should modify the manifest deployment files with the mounts to the SSL secrets files. 

- Gateway
  
  - To connect with an exteranl Gateway, update the **AQUA_SERVER** value with the gateway endpoint address in the *002_aqua_enforcer_configMaps.yaml* configMap manifest file.


## Deploy Aqua Enforcer using manifests

You can deploy Aqua enforcer manually using the manifest yaml files added in this directory. From the following instructions:
* Perform the steps 1 thru 3 only if you deploy the Enforcer in a cluster that does not have the Aqua namespace and service account
* Skip to step 4 if the cluster already has Aqua namespace and service account

Perform the following steps to deploy Aqua Enforcer manually:

1. Create a namespace (or an OpenShif project) by name **aqua**.

2. Create a docker-registry secret to aqua-registry for downloading images.

3. Create a service account by creating or applying the yaml file, *001_aqua_enforcer_serviceAccount.yaml*. 

4. Download, edit, and apply ConfigMap as required, using the yaml file, *002_aqua_enforcer_configMaps.yaml*.

5. Create secrets manually or download, edit, and apply the secrets yaml file as explained below:

   * The token secret is mandatory and used to authenticate the Aqua Enforcer over the Aqua Server. Pass the following command for authentication:


    ```SHELL
    $ kubectl create secret generic enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
    ```

     * Download, edit, and apply secrets manually, using the yaml file, *003_aqua_enforcer_secrets.yaml* to create the token and SSL cert secrets.

6. Deploy Aqua Enforcer as daemonset using the yaml file, *004_aqua_enforcer_daemonset.yaml*.

### Specific OpenShift notes
The deployment commands shown above use the **kubectl** cli, however they can be easliy replaced with the **oc** or **podman** cli commands, to work on all platofrms including OpenShift.

## Use Aquactl to prepare the deployment files
Aquactl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Aqua Enforcer using Manifests](#deploy-aqua-enforcer-using-manifests). Command shown in this section creates (downloads) manifests (yaml) files quickly and prepares them for the Aqua Enforcer deployment.

### Command Syntax

```SHELL
aquactl download enforcer [flags]
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

#### Aqua Enforcer configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --gateway-url (string) | Aqua Gateway URL (IP, DNS, or service name) and port, it defaults to **aqua-gateway:8443**|
| --token (string) | Deployment token for the Aqua Enforcer group, it defaults to **enforcer-token**|

The **--gateway-url** flag identifies an existing Aqua Gateway used to connect the Aqua Enforcer. This flag is not used to configure a new Gateway, as in *aquactl download all* or *aquactl download server*.

To get help on the Aquactl function, enter the following command:

```SHELL
aquactl download enforcer -h
```

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
aquactl download enforcer --platform gke --version 6.5
```