## Kube Enforcer

- Kube Enforcer running as single replica deployment provides runtime security for your kubernetes workloads and infrastructure. It uses native Kubernetes Admission Controller API ([ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/)) to automatically discover the cluster infrastructure and to assist in static risk analysis by generating related audit events for your review.

## Prerequisites

- Aqua registry access to pull images, Cluster access via kubectl, and RBAC authorization to deploy applications.

- Kube Enforcer token copied from server UI for authentication. The token is provisioned to the Enforcer as a secret.

- A PEM encoded CA bundle which will be used to validate the KubeEnforcer certificate.

- A PEM encoded SSL cert to configure KubeEnforcer

## Considerations

Please consider the following options while deploying kube enforcer.

- PEM encoded CA bundle and SSL certs
  - Please use [gen_ke_certs.sh](https://github.com/aquasecurity/deployments/tree/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/gen_ke_certs.sh) script to generate required CA bundle and SSL certificates. You can also refer to KubeEnforcer SSL considerations section to manually generate them.

- Mutual Auth
  - If you want to enable mutual auth between kube enforcer and gateway. Please refer to https://docs.aquasec.com

- Gateway
  - By default kube enforcer will connect to an internal gateway over aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi cluster deployment please update the **AQUA_GATEWAY_SECURE_ADDRESS** value with the external gateway end-point address followed by port number in 001_kube_enforcer_config.yaml file.

- By default, enforcers are deployed in non-privileged mode and note that protection is only applied to new or restarted containers.


## Deploy Kube Enforcer

Step 1-2 are only required if you are deploying Kube-Enforcer in a new cluster that doesn't have the Aqua's namespace and service-account. Otherwise, you can start with step 3.

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

3. **Create admission controller, service account, and the configMap**
   - Option A: Use shell script provided by Aqua
        - gen_ke_certs.sh script can be used to generate CA bundle (rootCA.crt), SSL certs (aqua_ke.key,aqua_ke.crt) and to deploy kube enforcer config
        
        ```shell
        $ curl -s https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/gen_ke_certs.sh | bash
        ```
   - Option B: Manual
        - Download manifest [here](https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/001_kube_enforcer_config.yaml)
        - Follow SSL considerations section below to generate CA bundle and SSL certs
        - Modify manifestfile to include PEM encoded CA bundle and SSL certs
        - Use kubectl to apply the modified manifest file config.
        
        ```shell
        $ kubectl apply -f 001_kube_enforcer_config.yaml
        ```

4.  **Create secrets for the Kube Enforcer deployment** 

    * The token secret is mandatory and used to authenticate the Kube Enforcer over server.

    ```shell
    $ kubectl create secret generic aqua-kube-enforcer-token -from-literal=token=<token_from_server_ui>
    ```
    * You can use kubectl command to create SSL cert secret
    
    ```shell
    $ kubectl create secret generic kube-enforcer-ssl --from-file aqua_ke.key --from-file aqua_ke.crt -n aqua
    ```

    * You can also manually modify the secret manifest file and use kubectl apply command to create token and SSL cert secrets

    ```shell
    https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/002_kube_enforcer_secrets.yaml
    ```

5. **Create KubeEnforcer Deployment**

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/003_kube_enforcer_deploy.yaml
   ```

## KubeEnforcer SSL Considerations

1. **Create Root CA**

   * Create Root Key

     ```shell
     openssl genrsa -des3 -out rootCA.key 4096
     ```

   * Create and self sign the Root Certificate

     ```shell
     openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/CN=admission_ca"
     ```

   * The content of rootCA.crt should be base64 encoded and replace the caBundle value at line number 15 in 001_kube_enforcer_config.yaml

     ```shell
     cat rootCA.crt | base64 -w 0
     ```

     

2. **Create a certificate**

   * Create the KubeEnforcer certificate key

     ```shell
     openssl genrsa -out aqua_ke.key 2048
     ```

   * Create the signing (csr)

     ```shell
     cat >server.conf <<EOF
     [req]
     req_extensions = v3_req
     distinguished_name = req_distinguished_name
     [req_distinguished_name]
     [ v3_req ]
     basicConstraints = CA:FALSE
     keyUsage = nonRepudiation, digitalSignature, keyEncipherment
     extendedKeyUsage = clientAuth, serverAuth
     EOF
     ```

     ```shell
     openssl req -new -sha256 \
     -key aqua_ke.key \
     -subj "/CN=aqua-kube-enforcer.aqua.svc" \
     -config server.conf \
     -out aqua_ke.csr
     ```

     

3. Generate the certificate using the aqua_ke.csr and key along with the CA Root key

   ```shell
   openssl x509 -req -in aqua_ke.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_ke.crt -days 1024 -sha256 -extensions v3_req -extfile server.conf 
   ```

   

4. Verify the certificate's content

   ```shell
   openssl x509 -in aqua_ke.crt -text -noout
   ```

5. Use the above generated aqua_ke.crt and aqua_ke.key files to create secrets for the Kube Enforcer deployment.

   ```shell
   $ kubectl create secret generic kube-enforcer-ssl \
   --from-file aqua_ke.key \
   --from-file aqua_ke.crt \
   -n aqua
   ```
