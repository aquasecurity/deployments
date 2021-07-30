## Aqua Scanner Overview

Aqua scanner scans container images, VMware Tanzu applications, and serverless functions for security issues such as vulnerabilities, sensitive data, and malware. Scanner registers container images with Aqua and imports results of scans already performed. For more information, refer to the product documentation, [Aqua Scanner Overview](https://docs.aquasec.com/docs/aqua-scanner). Aqua Scanner should be deployed on both the Aqua SaaS and Self-Hosted Enterprise editions.

This repository shows the manifest yaml files required to deploy Aqua Scanner on the following Kubernetes platforms:
* Kubernetes
* OpenShift
* Kubernetes engines: EKS, GKE, ICP, AKS, TKG, and TKGI

Before you follow the deployment steps explained below, Aqua strongly recommends you refer to the product documentation, [Deploy Aqua Scanner](https://docs.aquasec.com/docs/deploy-k8s-scanners) for detailed information.

## Specific OpenShift notes
Similar to deployment of Aqua Scanner using **kubectl** cli, you can also deploy using the **oc** or **podman** cli commands, to work on all platforms including OpenShift.

## Prerequisites

- Your Aqua credentials: username and password
- *Scanner* role permissions to authenicate over the Aqua server
- Define the following secrets in base64 encoding:
  - AQUA_SCANNER_USERNAME
  - AQUA_SCANNER_PASSWORD
  - AQUA_SERVER (Aqua Server URL or IP followed by the HTTPS port number)

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Deployment considerations

Consider the following options for deploying Aqua Scanner:

- It is recommended to deploy scanners close to your registry to decrease the network latency and improve scanning performance.

- **Mutual Auth / Custom SSL certs**: 
  - **To use private CA:** Prepare the SSL cert for the domain you choose to configure for the Aqua Server. You should modify the manifest deployment files with the mounts to the SSL secrets files at **/etc/ssl/certs**
  
  - **To use Aqua generated certs:** Populate root CA to the scanner deployment. To get this cert, connect to aqua instance and copy it from **/opt/aquasec/cert.pem**. 

## Deploy Scanner using manifests

You can deploy Aqua Scanner manually using the manifest yaml files added in this directory. You should run commands as mentioned in the respective steps. From the following instructions:
* Perform the steps 1 thru 3 only if you deploy the Scanner in a cluster that does not have the Aqua namespace and service account
* Skip to step 4 if the cluster already has Aqua namespace and service account

Perform the following steps to deploy Aqua Scanner manually:

1. Create a namespace (or an OpenShif project) by name aqua.

2. Create a docker-registry secret to aqua-registry for downloading images.

3. Create a service account by creating or applying the yaml file, *001_scanner_serviceAccount.yaml*.

4. Create secrets manually or download, edit, and apply the secrets yaml file, *002_scanner_secrets.yaml*.

5. Deploy Aqua Scanner using the yaml file, *003_scanner_deploy.yaml*.

## Automate Scanner deployment using Aquactl

Aquactl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Scanner using manifests](#deploy-scanner-using-manifests). Command shown in this section creates (downloads) manifests (yaml) files quickly and prepares them for the Scanner deployment.

### Command Syntax

```SHELL
aquactl download scanner [flags]
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

#### Aqua Scanner configuration

Flag and type              | Values                                                |
| ---------------------- | ------------------------------------------------------------ |
| --server-url (string) | Aqua Server URL (IP, domain, or service name) followed by an HTTPS port. It defaults to **aqua-web:443**|
| --username (string) | Username of an Aqua user with the Scanner role|
| --password (string) | Password for the username with the Scanner role|

To get help on the Aquactl function, enter the following command:

```SHELL
aquactl download scanner -h
```

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
aquactl download scanner --platform gke --version 6.5 \
--server-url 215.150.97.228:443 --output-dir aqua-scan-files
```