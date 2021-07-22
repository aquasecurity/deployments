## Aqua Enforcer Overview

The Aqua Enforcer, running as a DaemonSet deployment, provides runtime security for your Kubernetes workloads by blocking unauthorized deployments, monitoring and restricting runtime activities, and generating audit events for your review. Deployment of Aqua Enforcers is optional. For more information, refer the product documentation, [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview#section-aqua-enforcers) and [Aqua Enforcer](https://docs.aquasec.com/docs/aqua-enforcer).

## Prerequisites for manifest deployment

- Your Aqua credentials: username and password

- Access to Aqua registry to pull images, access to cluster through kubectl, and RBAC authorization to deploy applications

- Deployment token of the Aqua enforcer copied from the Aqua Server UI for authentication. Aqua uses this token to authenticate the enforcers and associate them with a specific enforcer group policy. When you deploy a new enforcer, you should provide this token as a Kubernetes secret. /to confirm this prereq with PM/

- Create or choose the relevant Enforcer group, and copy the group’s token from the Aqua UI, **Administration > Enforcers** page. For more information on the Enforcer groups and tokens, refer to [Aqua Enforcer Groups and Settings](https://docs.aquasec.com/docs/aqua-enforcer-groups-and-settings). /to know how to get enforcer group token and where to use this/

- If you plan to connect to an Aqua Server on a different cluster, make sure that you have the remote Aqua gateway address. /to confirm the purpose of this prereq/

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

Consider the following options for deploying the Aqua Enforcer DaemonSet:

- Mutual Auth / Custom SSL certs

  - Aqua uses self-signed certificates for secure communication between its components. If you require using your own CA authority, you need to prepare the SSL cert for the domain you choose to configure for the Aqua Server. You should modify the manifest deployment files with the mounts to the SSL secrets files. /to confirm this and get more information to add here/

- Gateway
  - By default, the Aqua Enforcer will connect to an internal gateway over the aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi-cluster deployment, you should update the **AQUA_SERVER** value with the external gateway endpoint address, followed by the port number, in the 002_aqua_enforcer_configMaps.yaml configMap manifest file.

- Deploy the Aqua enforcer DaemonSet
  - By default, the Aqua enforcer DaemonSet is deployed only on worker nodes. To additionally deploy the Aqua Enforcer on master nodes, daemonset yaml file should be edited for master nodes. For more information, refer to product documentation, [Deploy the Aqua Enforcer DaemonSet](https://docs.aquasec.com/docs/deploy-k8s-aqua-enforcers#section-step-6-deploy-the-aqua-enforcer-daemon-set).
  - Procedure for deploying the Aqua enforcer daemonset is different for TKGI platform is different platforms. For this specific procedure, refer to [Deploy the Aqua Enforcer DaemonSet](https://docs.aquasec.com/docs/deploy-k8s-aqua-enforcers#section-step-6-deploy-the-aqua-enforcer-daemon-set).

- By default, Enforcers are deployed in the non-privileged mode. Protection is applied only to new or restarted containers.

## Deploy Aqua Enforcer using manifests

You can deploy Aqua enforcer manually as a DaemonSet using the commands and manifests yaml files added in this directory. You should run commands as mentioned in the respective steps. From the following instructions:
* Perform the steps 1 thru 3 only if you deploy the Enforcer in a cluster that does not have the Aqua namespace and service account
* Skip to step 4 if the cluster already has Aqua namespace and service account

1. **Create namespace**

   ```SHELL
   $ kubectl create namespace aqua
   ```

2. **Create the docker-registry secret**

   ```shell
   $ kubectl create secret docker-registry aqua-registry \
   --docker-server=registry.aquasec.com \
   --docker-username=<your-name> \
   --docker-password=<your-password> \
   --docker-email=<your-email> -n aqua
   ```

3. **Create service account**

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/tree/6.5/2_enforcers/aqua_enforcer/manifests/001_aqua_enforcer_serviceAccount.yaml
   ```

4. **Define ConfigMap for the deployment**

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/tree/6.5/2_enforcers/aqua_enforcer/manifests/002_aqua_enforcer_configMaps.yaml
   ```

5. **Create secrets for the deployment**: Run the following commands to create secrets for the deployment:

     - The token secret is mandatory and used to authenticate the KubeEnforcer over the Aqua Server. You should pass the following command for authentication:

        ```SHELL
        $ kubectl create secret generic enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
        ```

      - You can also modify the secret manifest file manually using the following command and use kubectl apply command to create the token and SSL cert secrets.

        ```SHELL
        $ https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/  2_enforcers/aqua_enforcer/manifests/003_aqua_enforcer_secrets.yaml
        ```

6. **Deploy the Aqua Enforcer DaemonSet**: Perform the following steps to deploy Aqua enforcer for different use cases as explained:

    - By default, the Aqua Enforcer DaemonSet is deployed only on worker nodes using the deamonset yaml file. You should run the following command to deploy Aqua enforcer on all the platforms except TKGI. You should edit the daemonset yaml file to configure deploying Aqua enforcer for TKGI platform only. To deploy Aqua enforcer as a daemonset on all the platforms except TKGI, run the following shell command:

      ```SHELL
       $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/blob/6.5_dev/2_enforcers/aqua_enforcer/manifests/004_aqua_enforcer_daemonset.yaml
       ```

   - To deploy Aqua enforcer on master nodes in addition to the worker nodes, perform the following steps:
  
        a. Download the [004_aqua_enforcer_daemonset.yaml](https://github.com/KoppulaRajender/deployments/blob/6.5_dev/2_enforcers/aqua_enforcer/manifests/004_aqua_enforcer_daemonset.yaml) file.
        b. Add the following lines to the **spec.template.spec** section:

        ```SHELL
              tolerations:
              - key: node-role.Kubernetes.io/master
                effect: NoSchedule
        ```  
      c. Run the **kubectl apply -f** command on the edited file.

   - To deploy Aqua enforcer as a daemonset on the TKGI platform:

      a. Download the [004_aqua_enforcer_daemonset.yaml](https://github.com/KoppulaRajender/deployments/blob/6.5_dev/2_enforcers/aqua_enforcer/manifests/004_aqua_enforcer_daemonset.yaml) file.
      b. Locate the following lines in the yaml file

        ```SHELL
          - hostPath:
              path: /var/run
              type: ""
            name: var-run
      ```  
      c. In the hostpath line shown above, change **/var/run** to **/var/vcap/sys/run/docker**.
      d. Run the **kubectl apply -f** command on the edited file.

For detailed step-by-step instructions to deploy Aqua enforcer component by using these yaml files, refer to the product documentation, [Deploy Aqua Enforcer(s)](https://docs.aquasec.com/docs/deploy-k8s-aqua-enforcers).

## Deploy Aqua server using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the section, [Deploy Aqua Enforcer using Manifests](#deploy-aqua-enforcer-using-manifests). Command shown in this section creates (downloads) manifests (yaml files) that can be used to deploy the Aqua Enforcer component on a Kubernetes cluster.

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