## KubeEnforcer Starboard Overview

Starboard is an Aqua Security open-source tool that increases the effectiveness of Kubernetes security. Starboard is deployed by default, when you deploy KubeEnforcer.

When Starboard is deployed, it assesses workload compliance throughout the lifecycle of the workloads. This enables the KubeEnforcer to:
* Re-evaluate workload compliance during workload runtime, taking any workload and policy changes into account
* Reflect the results of compliance evaluation in the Aqua UI at all times, not only when workloads are created.

**Note:** When Starboard is not deployed, KubeEnforcer checks workloads for compliance only when the workloads are started.

To deploy KubeEnforcer with starboard:
- While performing the manual deployment, use the manifest yaml files specified in this directory.
- While deploying KubeEnforcer using Aquactl, add the relevant flag as specified in the section, [Deploy KubeEnforcer using Aquactl](#deploy-kubeenforcer-using-aquactl).

Before you follow the deployment steps explained below, Aqua strongly recommends you refer the product documentation, [Deploy Aqua KubeEnforcer(s) with Starboard](https://docs.aquasec.com/docs/deploy-k8s-aqua-kubeenforcers#section-starboard-co-requisite).

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

- **PEM-encoded CA bundle and SSL certs**: Use the *gen_ke_certs.sh* script to generate the required CA bundle, SSL certificates, and deploy the KubeEnforcer config. Refer to [KubeEnforcer SSL considerations](#kubeenforcer-ssl-considerations) section to generate CA bundle and SSL certificates manually.

- **Mutual Auth / Custom SSL certs**: Prepare the SSL cert for the domain you choose to configure for the Aqua Server. You should modify the manifest deployment files with the mounts to the SSL secrets files.

- **Gateway**: To connect with an external gateway in a multi-cluster deployment, update the **AQUA_GATEWAY_SECURE_ADDRESS** value with the Gateway endpoint address in the *001_kube_enforcer_config.yaml* file.

## Deploy KubeEnforcer using manifests

You can deploy KubeEnforcer with Starboard manually using the commands and manifests yaml files added in this directory. You should run commands as mentioned in the respective steps. From the following instructions:
* Perform the steps 1 and 2 only if you deploy the KubeEnforcer in a cluster that does not have the Aqua namespace and service account
* Skip to step 3 if the cluster already has Aqua namespace and service account

Perform the following steps to deploy KubeEnforcer manually:

1. Create a namespace (or an OpenShif project) by name **aqua**.

2. Create a docker-registry secret to aqua-registry for downloading images.

3. Deploy the KubeEnforcer config using one of the following options:
   - **Option A (Automatic)**: Use the shell script *gen_ke_certs.sh* provided by Aqua to generate CA bundle (rootCA.crt), SSL certs (aqua_ke.key, aqua_ke.crt), and deploy the KubeEnforcer config (use the config file from directory without any changes). Run the shell script *gen_ke_certs.sh* to deploy the KubeEnforcer configuration automatically.
        
   - **Option B (Manual)**:
  
        a. Download the manifest yaml file, *001_kube_enforcer_config.yaml*.

        b. Follow the [SSL considerations](#kubeenforcer-ssl-considerations) section to generate a CA bundle and SSL certs.

        c. Modify the config file to include a PEM-encoded CA bundle (caBundle).
        
        d. Apply the modified manifest file config.

4.  Create token and SSL secrets manually or download, edit, and apply the secrets yaml file as explained below:

    * Pass the following command to create the token secret that authenticates the KubeEnforcer over the Aqua Server:

      ```shell
      $ kubectl create secret generic aqua-kube-enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
      ```
    * Run the following command to create the SSL cert secret:
    
      ```shell
      $ kubectl create secret generic kube-enforcer-ssl --from-file aqua_ke.key --from-file aqua_ke.crt -n aqua
      ```

    * Download, edit, and apply secrets yaml file, *002_kube_enforcer_secrets.yaml* manually to create the token and SSL cert secrets.

5. Deploy KubeEnforcer using the yaml file, *003_kube_enforcer_deploy.yaml*.

### Specific OpenShift notes
The deployment commands shown above use the **kubectl** cli, however they can be easliy replaced with the **oc** or **podman** cli commands, to work on all platofrms including OpenShift.

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

To get help on the Aquactl function, enter the following command:

```SHELL
aquactl download kube-enforcer -h
```

After the manifests are created, follow the instructions that appear on the console to perform the actual deployment.

### Usage example 

```SHELL
aquactl download kube-enforcer --starboard --platform gke --version 6.5 \
--token <KUBE_ENFORCER_GROUP_TOKEN> \
--gateway-url 221.252.82.95:8443 --output-dir aqua-kube-enforcer-files
```

## KubeEnforcer SSL considerations
Following are the SSL considerations supporting deployment of KubeEnforcer:

1. Create root CA: Perform the following steps to create a root CA.

    a. Create root key:

      ```shell
      openssl genrsa -des3 -out rootCA.key 4096
      ```

    b. Create and self-sign the root certificate:

      ```shell
      openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/CN=admission_ca"
      ```

    c. Replace the caBundle value at line number 15 in *001_kube_enforcer_config.yaml* with the following command.

      ```shell
      cat rootCA.crt | base64 -w 0
      ```

2. Create the KubeEnforcer certificate: Perform the following steps to create a KubeEnforcer certificate.

    a. Create the KubeEnforcer certificate key:

      ```shell
      openssl genrsa -out aqua_ke.key 2048
      ```

    b. Create the signing (csr):

     ```shell
     cat >server.conf <<EOF
     [req]
     req_extensions = v3_req
     distinguished_name = req_distinguished_name
     [req_distinguished_name]
     [alt_names ]
     DNS.1 = aqua-kube-enforcer.aqua.svc
     DNS.2 = aqua-kube-enforcer.aqua.svc.cluster.local
     [ v3_req ]
     basicConstraints = CA:FALSE
     keyUsage = nonRepudiation, digitalSignature, keyEncipherment
     extendedKeyUsage = clientAuth, serverAuth
     subjectAltName = @alt_names
     EOF
     ```

     ```shell
     openssl req -new -sha256 \
     -key aqua_ke.key \
     -subj "/CN=aqua-kube-enforcer.aqua.svc" \
     -config server.conf \
     -out aqua_ke.csr
     ```

3. Generate the certificate using the aqua_ke.csr, root certificate, and the CA root key:

   ```shell
   openssl x509 -req -in aqua_ke.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_ke.crt -days 1024 -sha256 -extensions v3_req -extfile server.conf 
   ``` 

4. Verify the certificate's content:

   ```shell
   openssl x509 -in aqua_ke.crt -text -noout
   ```

5. Use the aqua_ke.crt and aqua_ke.key files (generated above) to create SSL cert secrets for the KubeEnforcer deployment:

   ```shell
   $ kubectl create secret generic kube-enforcer-ssl \
   --from-file aqua_ke.key \
   --from-file aqua_ke.crt \
   -n aqua
   ```