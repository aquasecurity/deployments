## Overview

The quick-start deployment can be used to deploy Aqua Self-Hosted Enterprise on your Kubernetes cluster quickly and easily. It is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test but not for production environments.

For production usage, enterprise-grade deployments, advanced use cases, and deployment on other Kubernetes platforms, deploy Aqua Enterprise with the required Aqua components (such as server, enforcers, scanner, so on.) on your orchestration platform. For more information, refer to the product documentation, [Deploy Aqua Enterprise](https://docs.aquasec.com/docs/deployment-overview).

The quick-start deployment supports the following Kubernetes platforms:
* Kubernetes
* AKS (Microsoft Azure Kubernetes Service)
* EKS (Amazon Elastic Kubernetes Service)
* GKE (Google Kubernetes Engine)

Deployment commands shown in this file uses **kubectl** cli, however they can easliy be replaced with the **oc** cli commands.

Before you start using the quick-start deployment method documented in this reposiory, Aqua strongly recommends you to refer the product documentation, [Quick-Start Guide for Kubernetes](https://docs.aquasec.com/docs/quick-start-guide-for-kubernetes).

## Prerequisites
* Your Aqua credentials: username and password
* Your Aqua Enterprise License Token
* Access to the target Kubernetes cluster

## Configuration of Enforcers and storage

Through the quick-start deployment method, Aqua Enforcer is deployed to provide runtime security for your Kubernetes workloads. In addition to Aqua Enforcer, KubeEnforcer can also be deployed. If your Kubernetes cluster has shared storage, Aqua can be deployed to use the same. If you use Minikube or your cluster does not have shared storage, Aqua can be deployed using the host path for persistent storage. 

The following table shows different manifest yaml files that can be used to deploy Aqua through quick-start method:

| File                                   | Purpose                                                                                             |
|----------------------------------------|---------------------------------------------------------------------------------------------------|
| aqua-csp-quick-DaemonSet-hostPath.yaml | Deploy Aqua Enterprise with the Aqua Enforcer only, and use the host-path for storage             |
| aqua-csp-quick-DaemonSet-storage.yaml  | Deploy Aqua Enterprise with the Aqua Enforcer only, and use default-storage                       |
| aqua-csp-quick-default-storage.yaml    | Deploy Aqua Enterprise with the Aqua Enforcer and KubeEnforcer, and use default-storage           |
| aqua-csp-quick-hostpath.yaml           | Deploy Aqua Enterprise with the Aqua Enforcer and KubeEnforcer, and use the host-path for storage |

## Pre-deployment

You can skip any of the steps if you have already performed.

**Step 1. Create a namespace by name aqua (if not already done).**

```SHELL
$ kubectl create namespace aqua
```

**Step 2. Create a docker-registry secret (if not already done).**

   ```SHELL
   $ kubectl create secret docker-registry aqua-registry \
--docker-server=registry.aquasec.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
-n aqua
   ```

## Deploy Aqua Enterprise

Deploy Aqua Enterprise using the required yaml file mentioned in the current directory as per your use case. For example:

```SHELL
$ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/6.5/quick_start/kubernetes_and_openshift/manifests/aqua-csp-quick-DaemonSet-hostPath.yaml
```

For more information on selecting the yaml file that you need, refer to the [Configuration of Enforcers and storage](#configuration-of-enforcers-and-storage) section.


1. To access the Aqua Enterprise console on your Kubernetes platform, run the following command to get the external IP of the console:

    ```SHELL
    $ kubectl get svc -n aqua
    ```

2. If you have deployed Aqua Enterprise on Minikube, run the following commands to get the external IP of the console:

    ```SHELL
    $ minikube tunnel
    $ kubectl get svc -n aqua
    ```

When the **aqua-web** service is ready, you can access it from your browser through the following url:

    ```SHELL
    http://<aqua-web service>:<aqua-web port>
    ```

## Troubleshooting to access Aqua Enterprise

If you did not define a default load-balancer for your Kubernetes cluster, aqua-web's public service IP status will remain frozen as "pending", after deploying through quick-start method. In this case, you can access Aqua Enterprise using a client-side kubectl tunnel. To access Aqua Enterprise:

1. Run the following commands to get aqua-web’s cluster IP and use the kubectl port-forward command in a separate window to open the tunnel.

    ```SHELL
    $ kubectl get pods -n aqua
    $ kubectl port-forward -n aqua aqua-web <LOCAL_TUNNEL_PORT>:<AQUA_POD_CLUSTER_IP>
    ```

2. In your browser, run the following url to access Aqua Enterprise:

    ```SHELL
    http://localhost:<LOCAL_TUNNEL_PORT>
    ```

## KubeEnforcer SSL considerations
Following are the SSL considerations supporting deployment of Aqua Enterprise with KubeEnforcer through quick-start method:

1. Create root CA: Perform the following steps to create a root CA.

    a. Create root key:

     ```shell
     openssl genrsa -des3 -out rootCA.key 4096
     ```

    b. Create and self-sign the root certificate:

     ```shell
     openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/CN=admission_ca"
     ```

2. Create the KubeEnforcer certificate: Perform the following steps to create a certificate.

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
