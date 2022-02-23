## Aqua KubeEnforcer

- The Aqua KubeEnforcer, running as a single-replica deployment, provides runtime security for your Kubernetes workloads and infrastructure. It uses the Kubernetes native Admission Controller API:
  - [MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook) is invoked first, and can modify objects sent to the API server to enforce custom defaults like Pod Enforcer injection into the pods.
  - [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) is invoked next. It can reject requests to enforce custom policies.
  - The KubeEnforcer can automatically discover the cluster infrastructure and will assist in static risk analysis by running Kube-hunter scans.
  - The KubeEnforcer generates audit events for your review.

## Prerequisites

- Aqua registry access to pull images, cluster access via kubectl, and RBAC authorization to deploy applications

- The KubeEnforcer deployment token copied from the Aqua Enterprise Server (console) UI for authentication. The token is provisioned to the KubeEnforcer as a secret

- A PEM-encoded CA bundle which will be used to validate the KubeEnforcer certificate

- A PEM-encoded SSL cert to configure the KubeEnforcer

## Considerations

Please consider the following options for deploying the KubeEnforcer.

- PEM-encoded CA bundle and SSL certs
  - Use the [gen_ke_certs.sh](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/gen_ke_certs.sh) script to generate the required CA bundle and SSL certificates. You can also refer to KubeEnforcer SSL considerations section to manually generate them.

- Mutual Auth
  - If you want to enable mutual auth between the KubeEnforcer and the Gateway, refer to the [Aqua Enterprise documentation portal](https://docs.aquasec.com/v5.3/).

- Gateway
  - By default, the KubeEnforcer will connect to an internal gateway over the aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi-cluster deployment, you will need to update the **AQUA_GATEWAY_SECURE_ADDRESS** value with the external gateway endpoint address, followed by the port number, in the 001_kube_enforcer_config.yaml file.

- By default, KubeEnforcers are deployed in non-privileged mode. Note that protection is only applied to new or restarted containers.

## Deploy the KubeEnforcer

Step 1-2 are required only if you are deploying the KubeEnforcer in a new cluster that doesn't have the Aqua namespace and service-account. Otherwise, you can start with step 3.

1. **Create namespace**

   ```SHELL
   kubectl create namespace aqua
   ```

2. **Create the docker-registry secret**

   ```shell
   kubectl create secret docker-registry aqua-registry \
   --docker-server=registry.aquasec.com \
   --docker-username=<your-name> \
   --docker-password=<your-password> \
   --docker-email=<your-email> -n aqua
   ```

3. **Create admission controller, service account, and the ConfigMap**
   - Option A: Use the shell script provided by Aqua
        - gen_ke_certs.sh script can be used to generate CA bundle (rootCA.crt), SSL certs (aqua_ke.key,aqua_ke.crt) and to deploy the KubeEnforcer config
        
        ```shell
        curl -s https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/gen_ke_certs.sh | bash
        ```
   - Option B: Manual
        - Download the [manifest](https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/001_kube_enforcer_config.yaml).
        - Follow the "SSL considerations" section below to generate a CA bundle and SSL certs.
        - Modify the manifest file to include a PEM-encoded CA bundle (caBundle).
        - Use kubectl to apply the modified manifest file config.
        
        ```shell
        kubectl apply -f 001_kube_enforcer_config.yaml
        ```

4.  **Create secrets for the KubeEnforcer deployment** 

    * The token secret is mandatory and used to authenticate the KubeEnforcer over the Aqua Server.

    ```shell
    kubectl create secret generic aqua-kube-enforcer-token --from-literal=token=<token_from_server_ui> -n aqua
    ```
    * You can use kubectl command to create the SSL cert secret:
    
    ```shell
    kubectl create secret generic kube-enforcer-ssl --from-file aqua_ke.key --from-file aqua_ke.crt -n aqua
    ```

    * You can also manually modify the secret manifest file and use kubectl apply command to create the token and SSL cert secrets:

    ```shell
    https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/002_kube_enforcer_secrets.yaml
    ```
***Note: For KubeEnforcer deployment in OpenShift environments***
  * Prior to deployment of the KubeEnforcer, copy and run these commands:
      ```shell
      oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:aqua:aqua-kube-enforcer-sa
      oc adm policy add-scc-to-user privileged system:serviceaccount:aqua:aqua-kube-enforcer-sa
      ```

5. **Create the KubeEnforcer deployment**

   ```shell
   kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.2/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/003_kube_enforcer_deploy.yaml
   ```

## KubeEnforcer SSL considerations

1. **Create root CA**

   * Create root key:

     ```shell
     openssl genrsa -des3 -out rootCA.key 4096
     ```

   * Create and self-sign the root certificate:

     ```shell
     openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/CN=admission_ca"
     ```

   * The content of rootCA.crt should be base64-encoded and replace the caBundle value at line number 15 in 001_kube_enforcer_config.yaml:

     ```shell
     cat rootCA.crt | base64 -w 0
     ```

2. **Create a certificate**

   * Create the KubeEnforcer certificate key:

     ```shell
     openssl genrsa -out aqua_ke.key 2048
     ```

   * Create the signing (csr):

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
   kubectl create secret generic kube-enforcer-ssl \
   --from-file aqua_ke.key \
   --from-file aqua_ke.crt \
   -n aqua
   ```
