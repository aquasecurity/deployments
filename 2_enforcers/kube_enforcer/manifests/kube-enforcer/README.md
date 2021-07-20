## Aqua KubeEnforcer Overview

- The Aqua KubeEnforcer, running as a single-replica deployment, provides runtime security for your Kubernetes workloads and infrastructure. It uses the following Kubernetes native Admission Controller APIs:
  - [MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook) is invoked first, and can modify objects sent to the API server to enforce custom defaults like Pod Enforcer injection into the pods.
  - [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) is invoked next. It can reject requests to enforce custom policies.

The KubeEnforcer can automatically discover the cluster infrastructure and will assist in static risk analysis by running Kube-hunter scans. The KubeEnforcer generates audit events for your review. For more information, refer to product documentation, [Aqua KubeEnforcer](https://docs.aquasec.com/docs/kubeenforcer).

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
  - Use the [gen_ke_certs.sh](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/manifests/kube-enforcer/gen_ke_certs.sh) script to generate the required CA bundle and SSL certificates. You can also refer to [KubeEnforcer SSL considerations](#kubeenforcer-ssl-considerations) section to manually generate them.

- Mutual Auth
  - Aqua uses self-signed certificates for secure communication between its components (KubeEnforcer and Gateway). If you require using your own CA authority, you need to prepare the SSL cert for the domain you choose to configure for the Aqua Server. You should modify the manifest deployment files with the mounts to the SSL secrets files.

- Gateway
  - By default, the KubeEnforcer connects to an internal gateway over the aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi-cluster deployment, you should update the **AQUA_GATEWAY_SECURE_ADDRESS** value with the external gateway endpoint address, followed by the port number, in the 001_kube_enforcer_config.yaml file.

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
   - **Option A (Automatic)**: Use the shell script **gen_ke_certs.sh** provided by Aqua to generate CA bundle (rootCA.crt), SSL certs (aqua_ke.key, aqua_ke.crt), and create the KubeEnforcer configuration file. Run the following command to create the KubeEnforcer configuration file automatically.
        
        ```shell
        $ curl -s https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/gen_ke_certs.sh | bash
        ```
   - **Option B (Manual)**: Perform the following steps to create the KubeEnforcer configuration file manually:
  
    a. Download the [manifest](https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/001_kube_enforcer_config.yaml).
    b. Follow the [SSL considerations](#kubeenforcer-ssl-considerations) section below to generate a CA bundle and SSL certs.
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
      $ kubectl create secret generic kube-enforcer-ssl --from-file aqua_ke.key --from-file aqua_ke.crt -n aqua
      ```

    * You can also modify the secret manifest file manually and use kubectl apply command to create the token and SSL cert secrets as shown in the following command:

      ```shell
      $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/002_kube_enforcer_secrets.yaml
      ```

5. **Create the KubeEnforcer deployment**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/003_kube_enforcer_deploy.yaml
   ```

## KubeEnforcer SSL considerations

1. Create root CA: Perform the following steps to create a root CA.

    a. Create root key:

     ```shell
     openssl genrsa -des3 -out rootCA.key 4096
     ```

    b. Create and self-sign the root certificate:

     ```shell
     openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/CN=admission_ca"
     ```

    c. Replace the caBundle value at line number 15 in *001_kube_enforcer_config.yaml* with the following command. The content of rootCA.crt should be base64-encoded.

     ```shell
     cat rootCA.crt | base64 -w 0
     ```

2. Create a certificate: Perform the following steps to create a certificate.

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

3. Generate the certificate using the aqua_ke.csr and key along with the CA root key:

   ```shell
   openssl x509 -req -in aqua_ke.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_ke.crt -days 1024 -sha256 -extensions v3_req -extfile server.conf 
   ``` 

4. Verify the certificate's content:

   ```shell
   openssl x509 -in aqua_ke.crt -text -noout
   ```

5. Use the aqua_ke.crt and aqua_ke.key files (generated above) to create secrets for the KubeEnforcer deployment:

   ```shell
   $ kubectl create secret generic kube-enforcer-ssl \
   --from-file aqua_ke.key \
   --from-file aqua_ke.crt \
   -n aqua
   ```
## Deploy KubeEnforcer using Aquactl
Aquactl is the command-line utility to automate the deployment steps mentioned in the previous section, Manifests. This utility creates (downloads) manifests that are customized to your specifications. For more information on the usage of Aquactl to deploy KubeEnforcer, refer to the product documentation, [Aquactl: Download Aqua KubeEnforcer Manifests](https://docs.aquasec.com/docs/aquactl-download-manifests-kubeenforcer).