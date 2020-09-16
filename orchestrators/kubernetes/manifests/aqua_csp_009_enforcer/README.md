## The Enforcer Family

- Enforcers provide runtime security for your workloads and infrastructure, and generate related audit events for your review.
   - **Aqua Enforcer**: Running on Kubernetes as DaemonSet to block deployment; monitor/restrict runtime activities.
   - **Aqua KubeEnforcer**: Running on Kubernetes as single replica deployment to block deployment. It can automatically discover Kubernetes cluster infrastructure in order to assist in static risk analysis.

## Prerequisites

- Aqua registry access to pull images, Cluster access via kubectl, and RBAC authorization to deploy applications, Capacity requirements.

- Aqua uses a token to authenticate the Enforcers. In order to deploy a new Enforcer you will need to access Aqua's console and get the relevant token from the Enforcer view. The token is provisioned to the Enforcer as a secret.

- If you plan to connect to an Aqua Server on a different cluster then you'll need the remote gateway address

## Considerations

Before you deploy the Aqua Enforcer, you should consider the following options -

- Mutual Auth / Custom SSL certs

  - If you want to enable mutual auth between aqua components or if you want to use your own SSL certificates. Please refer to SSL considerations

- By default, enforcers are deployed in non-privileged mode and note that protection is only applied to new or restarted containers.

## Deploy Aqua Enforcer

Aqua Enforcer is an optional enforcement option that deployed as a daemon-set.

For more information please read https://docs.aquasec.com/docs/aqua-enforcer

Step 1-3 are only required if you are deploying the Enforcer in a cluster that doesn't have the Aqua's namespace and service-account. Otherwise, you can start with step 4.

1. **Create namespace**
   
   ```SHELL
   $ kubectl create namespace aqua
   ```
2. **Create the docker-registry secret**

   ```SHELL
   $ kubectl create secret docker-registry aqua-registry \
   --docker-server=registry.aquasec.com \
   --docker-username=<your-name> \
   --docker-password=<your-pword> \
   --docker-email=<your-email> \
   -n aqua
   ```

3. **Create platform specific RBAC**

   * RBAC definitions can vary between platforms. Please choose the right aqua_sa.yaml for your platform

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_002_RBAC/<<platform>>/aqua_sa.yaml
   ```

4. **Define the configMap for the deployment.**

   * By default Aqua enforcer will connect to an internal gateway over aqua-gateway service name on port 8443.
   * If you want to connect to an external Aqua instance in a multi cluster deployment please update **AQUA_SERVER** value in 001_aqua_enforcer_configMaps.yaml manifest file.
   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/001_aqua_enforcer_configMaps.yaml
   ```
   
5. **Create secrets for the Enforcer deployment.**

   * The only mandatory secret is the **token** that authenticates the Enforcer over Aqua server.

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/002_aqua_enforcer_secrets.yaml
   ```

6. **Create Aqua Enforcer DaemonSet**

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/aqua_enforcer/003_aqua_enforcer_daemonset.yaml
   ```

## Deploy Kube Enforcer

The Kube-Enforcer is an optional enforcement option that deployed as an admission-control. 

For more information please read https://docs.aquasec.com/docs/kubeenforcer

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

   * The Aqua KubeEnforcer uses native Kubernetes functionality to perform two functions, without the need for an Aqua Enforcer. One KubeEnforcer can be deployed on each Kubernetes cluster.
   * This functionality is implemented using a [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/), and is deployed as a pod on a single node in a cluster. To work in the Kubernetes environment, the KubeEnforcer is configured to communicate with the Kubernetes API server located on the master node over a TLS connection
   * Kube enforcer container requires SSL certificates generated form the admission controller CA root cert. 
   * Aqua Kube Enforcer admission controller is packaged with a default CA root cert. If you want to use your own CA authority, Please refer to **KubeEnforcer SSL considerations** section below.
   * By default Aqua Kube Enforcer will connect to an internal gateway over aqua-gateway service name on port 8443.
   * If you want to connect to an external Aqua gateway in a multi cluster deployment please update the **AQUA_GATEWAY_SECURE_ADDRESS** value with the external gateway end-point address in 001_kube_enforcer_config.yaml

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/001_kube_enforcer_config.yaml
   ```

4.  **Create secrets for the Kube Enforcer deployment** 

    * The token secret is mandatory and used to identify the Kube Enforcer to the Server.
    * You can use kubectl command to create kube enforcer SSL secret 

    ```shell
    $ kubectl create secret generic kube-enforcer-ssl \
    --from-file aqua_ke.key \
    --from-file aqua_ke.crt \
    -n aqua
    ```

    * You can also modify the secret manifest file to create kube enforcer SSL secret

    ```shell
    $ Kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/002_kube_enforcer_secrets.yaml
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
   openssl x509 -req -in aqua_ke.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_ke.crt -days 1024 -sha256 extensions v3_req -extfile server.conf 
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