## Aqua KubeEnforcer Advanced Starboard

Aqua KubeEnforcer Advanced Starboard is the Aqua KubeEnforcer component with Starboard capability deployed in a special Advanced configuration.

Aqua KubeEnforcer Advanced is a method of deploying Aqua KubeEnforcer in a special Advanced configuration while using KubeEnforcers for Pod Enforcer injection. This causes Pod Enforcer traffic to be routed to the KubeEnforcers through a local envoy, which then forwards the traffic to an Aqua Gateway. This configuration improves performance and reduces remote network connections between pods and Gateways. For more information, refer to product documentation, [Advanced Deployment for Aqua KubeEnforcer](https://docs.aquasec.com/docs/deploy-k8s-aqua-kubeenforcers#section-advanced-deployment-for-pod-enforcer-injection).

Starboard is an Aqua Security open-source tool that increases the effectiveness of Kubernetes security. Starboard is deployed by default, when you deploy KubeEnforcer.

When Starboard is deployed, it assesses workload compliance throughout the lifecycle of the workloads. This enables the KubeEnforcer to:
* Re-evaluate workload compliance during workload runtime, taking any workload and policy changes into account
* Reflect the results of compliance evaluation in the Aqua UI at all times, not only when workloads are created.

To deploy KubeEnforcer with Advanced configuration:
- While performing the manual deployment, use the manifest yaml files in the [kube_enforcer_advanced](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/manifests/kube_enforcer_advanced) directory.
- While deploying KubeEnforcer using Aquactl, add the relevant flag as specified in the section, [Deploy KubeEnforcer using Aquactl](#deploy-kubeenforcer-using-aquactl).

## Prerequisites

- Your Aqua credentials: username and password

- Access to Aqua registry to pull images, access to cluster through kubectl, and RBAC authorization to deploy applications

- The KubeEnforcer deployment token copied from the Aqua Server UI for authentication. Aqua uses this token to authenticate the KubeEnforcers and associate them with a specific enforcer group policy. When you deploy a new KubeEnforcer, you should provide this token as a Kubernetes secret

- A PEM-encoded CA bundle which will be used to validate the KubeEnforcer certificate

- A PEM-encoded SSL cert to configure the KubeEnforcer

- If you plan to connect to an Aqua Server on a different cluster, make sure that you have the remote Aqua gateway address.

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

Consider the following options for deploying the KubeEnforcer:

- PEM-encoded CA bundle and SSL certs
  - Use the [gen_ke_certs.sh](https://github.com/aquasecurity/deployments/tree/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer_advanced_starboard/gen_ke_certs.sh) script to generate the required CA bundle and SSL certificates. You can also refer to KubeEnforcer [SSL considerations](#kubeenforcer-ssl-considerations) section to manually generate them.

- Mutual Auth
  - Aqua uses self-signed certificates for secure communication between its components (KubeEnforcer and Gateway). If you require using your own CA authority, you need to prepare the SSL cert for the domain you choose to configure for the Aqua Server. You should modify the manifest deployment files with the mounts to the SSL secrets files.

- Gateway
  - By default, the KubeEnforcer connects to an internal gateway over the aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi-cluster deployment, you should update the **AQUA_GATEWAY_SECURE_ADDRESS** value with the external gateway endpoint address, followed by the port number, in the *001_kube_enforcer_config.yaml file*.

- By default, KubeEnforcers are deployed in the non-privileged mode. Note that protection is only applied to new or restarted containers.

## Deploy the KubeEnforcer

You can deploy KubeEnforcer manually using the commands and manifests yaml files added in this directory. You should run commands as mentioned in the respective steps. From the following instructions:
* Perform the steps 1 and 2 only if you deploy the KubeEnforcer in a cluster that does not have the Aqua namespace and service account
* Skip to step 3 if the cluster already has Aqua namespace and service account

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

3. **Create admission controller, service account, and the ConfigMap**
   - **Option A (Automatic)**: Use the shell script **gen_ke_certs.sh** provided by Aqua to generate CA bundle (rootCA.crt), SSL certs (server.key,server.crt), and create the KubeEnforcer configuration file. Run the following command to create the KubeEnforcer configuration file automatically.
        
        ```shell
        $ curl -s https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer_advanced_starboard/gen_ke_certs.sh | bash
        ```
   - **Option B (Manual)**: Perform the following steps to create the KubeEnforcer configuration file manually:

      a. Download the [manifest](https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer_advanced_starboard/001_kube_enforcer_config.yaml).
      
      b. Follow the [SSL considerations](#kubeenforcer-ssl-considerations) section to generate a CA bundle and SSL certs.
      
      c. Modify the manifest file to include a PEM-encoded CA bundle (caBundle).
      
      d. Use kubectl to apply the modified manifest file config.
        
        ```shell
        $ kubectl apply -f 001_kube_enforcer_config.yaml
        ```

4.  **Create secrets for the KubeEnforcer deployment** 

    * The token secret is mandatory and used to authenticate the KubeEnforcer over the Aqua Server. You should pass the following command for authentication:

      ```shell
      $ kubectl create secret generic aqua-kube-enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
      ```
    * You should use the following kubectl command to create the SSL cert secret:
    
      ```shell
      $ kubectl create secret generic aqua-kube-enforcer-certs--from-file server.key --from-file server.crt -n aqua
      ```

    * You can also manually modify the secret manifest file and use kubectl apply command to create the token and SSL cert secrets as shown in the following command:

      ```shell
      $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer_advanced_starboard/002_kube_enforcer_secrets.yaml
      ```

5. **Create the KubeEnforcer deployment**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer_advanced_starboard/003_kube_enforcer_deploy.yaml
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

   * Replace the caBundle value at line number 15 in *001_kube_enforcer_config.yaml* with the following command. The content of rootCA.crt should be base64-encoded

     ```shell
     cat rootCA.crt | base64 -w 0
     ```

2. Create a certificate: Perform the following steps to create a certificate.

    a. Create the KubeEnforcer certificate key:

     ```shell
     openssl genrsa -out server.key 2048
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
     -key server.key \
     -subj "/CN=aqua-kube-enforcer.aqua.svc" \
     -config server.conf \
     -out aqua_ke.csr
     ```

3. Generate the certificate using the aqua_ke.csr and key along with the CA root key:

   ```shell
   openssl x509 -req -in aqua_ke.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 1024 -sha256 -extensions v3_req -extfile server.conf 
   ``` 

4. Verify the certificate's content:

   ```shell
   openssl x509 -in server.crt -text -noout
   ```

5. Use the server.crt and server.key files (generated above) to create secrets for the KubeEnforcer deployment:

   ```shell
   $ kubectl create secret generic kube-enforcer-ssl \
   --from-file server.key \
   --from-file server.crt \
   -n aqua
   ```

## Deploy Aqua KubeEnforcer without Starboard

If you do not want to deploy Starboard for any reason, you should modify *001_kube_enforcer_config.yaml*, while using in the KubeEnforcer deployment procedure. To exclude Starboard from the KubeEnforcer, remove all the text from the following line through the end of the file:

```shell
# Starboard resource yamls#############
```

## Deploy KubeEnforcer advanced Starboard using Aquactl

Aquactl is the command-line utility to automate the deployment steps mentioned in the previous section, Manifests. This utility creates (downloads) manifests that are customized to your specifications. To deploy Aqua KubeEnforcer with Starboard in the Advanced configuration, include the **--advanced-configuration** and **--starboard** flags in the aquactl download command syntax, in addition to the required flags for KubeEnforcer. For more information on the usage of Aquactl to deploy KubeEnforcer, refer to the product documentation, [Aquactl: Download Aqua KubeEnforcer Manifests](https://docs.aquasec.com/docs/aquactl-download-manifests-kubeenforcer).


