## Overview

The quick-start deployment can be used to deploy Aqua Self-Hosted Enterprise on your Kubernetes cluster quickly and easily. It is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test but not for production environments.

For production usage, enterprise-grade deployments, advanced use cases, and deployment on other Kubernetes platforms, deploy Aqua Enterprise with the required Aqua components (such as server, enforcers, scanner, so on.) on your orchestration platform. For more information, refer to the Product documentation, [Deploy Aqua Enterprise](https://docs.aquasec.com/docs/deployment-overview).

The quick-start deployment supports the following Kubernetes platforms:
* Kubernetes
* AKS (Microsoft Azure Kubernetes Service)
* EKS (Amazon Elastic Kubernetes Service)
* GKE (Google Kubernetes Engine)

Deployment commands shown in this file uses **kubectl** cli, however they can easily be replaced with the **oc** cli commands.

Before you start using the quick-start deployment method documented in this repository, Aqua strongly recommends you to refer the product documentation, [Quick-Start Guide for Kubernetes](https://docs.aquasec.com/docs/quick-start-guide-for-kubernetes).

## Prerequisites
* Your Aqua credentials: username and password
* Your Aqua Enterprise License Token
* Access to the target Kubernetes cluster

## Configuration for Enforcers and storage

Through the quick-start deployment method, Aqua Enforcer is deployed to provide runtime security for your Kubernetes workloads. In addition to Aqua Enforcer, KubeEnforcer can also be deployed. If your Kubernetes cluster has shared storage, Aqua can be deployed to use the same. If you use Minikube or your cluster does not have shared storage, Aqua can be deployed using the host path for persistent storage. 

The following table shows different manifest yaml files that can be used to deploy Aqua through quick-start method:

| File                                   | Purpose                                                                                             |
|----------------------------------------|---------------------------------------------------------------------------------------------------|
| aqua-csp-quick-DaemonSet-hostPath.yaml | Deploy Aqua Enterprise with the Aqua Enforcer only, and use the host-path for storage             |
| aqua-csp-quick-DaemonSet-storage.yaml  | Deploy Aqua Enterprise with the Aqua Enforcer only, and use default-storage                       |
| aqua-csp-quick-default-storage.yaml    | Deploy Aqua Enterprise with the Aqua Enforcer and KubeEnforcer, and use default-storage           |
| aqua-csp-quick-hostpath.yaml           | Deploy Aqua Enterprise with the Aqua Enforcer and KubeEnforcer, and use the host-path for storage |

## Pre-deployment

You can skip any step if you have already performed.

**Step 1. Create a namespace by name aqua (if not already done).**

```SHELL
kubectl create namespace aqua
```

**Step 2. Create a docker-registry secret (if not already done).**

```SHELL
kubectl create secret docker-registry aqua-registry \
--docker-server=registry.aquasec.com \
--docker-username=<your-name> \
--docker-password=<your-pword> \
-n aqua
```

## Deploy Aqua Enterprise in your cluster

Deploy Aqua Enterprise using the required yaml file mentioned in the current directory as per your use case. For example:

```SHELL
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/quick_start/kubernetes_and_openshift/manifests/aqua-csp-quick-DaemonSet-hostPath.yaml
```

For more information on selecting the yaml file that you need, refer to the [Configuration of Enforcers and storage](#configuration-of-enforcers-and-storage) section.

### Deploying with KubeEnforcer

The files that deploy KubeEnforcer (*aqua-csp-quick-default-storage.yaml* and *aqua-csp-quick-hostpath.yaml*) do not ship a certificate for the KubeEnforcer admission webhook. Generate one and add it to the manifest before you apply it. The examples use *aqua-csp-quick-hostpath.yaml*.

**Step 1. Download the manifest.**

```SHELL
curl -O https://raw.githubusercontent.com/aquasecurity/deployments/main/quick_start/kubernetes_and_openshift/manifests/aqua-csp-quick-hostpath.yaml
```

**Step 2. Generate the CA bundle and SSL certificates** with the KubeEnforcer script. Answer `y` to proceed. When it offers to deploy the KubeEnforcer config, answer `N`: the quick-start manifest deploys KubeEnforcer itself. The script creates *rootCA.crt*, *aqua_ke.crt* and *aqua_ke.key* in the current directory.

```SHELL
curl -s https://raw.githubusercontent.com/aquasecurity/deployments/main/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer/gen_ke_certs.sh | bash
```

After `N`, the script prints "User abandoned. Please deploy KubeEnforcer config from 001_kube_enforcer_config.yaml manifest using kubectl" and exits. This is expected: do not apply *001_kube_enforcer_config.yaml*, continue with step 3.

**Step 3. Add the CA bundle to the manifest.**

```SHELL
sed -i'.original' "s/caBundle.*/caBundle: $(cat rootCA.crt | base64 | tr -d '\n')/g" aqua-csp-quick-hostpath.yaml
```

**Step 4. Create the SSL cert secret.**

```SHELL
kubectl create secret generic kube-enforcer-ssl --from-file aqua_ke.key --from-file aqua_ke.crt -n aqua
```

**Step 5. Deploy Aqua Enterprise.**

```SHELL
kubectl apply -f aqua-csp-quick-hostpath.yaml
```

#### Renewing the KubeEnforcer certificate

The generated SSL certificate is valid for 365 days. To renew it without re-applying the manifest:

**Step 1. Generate new certificates** by running step 2 of [Deploying with KubeEnforcer](#deploying-with-kubeenforcer) again, answering the same way.

**Step 2. Replace the SSL cert secret.**

```SHELL
kubectl create secret generic kube-enforcer-ssl --from-file aqua_ke.key --from-file aqua_ke.crt -n aqua --dry-run=client -o yaml | kubectl replace -f -
```

**Step 3. Update the CA bundle in both webhooks and in the local manifest.**

```SHELL
CA=$(cat rootCA.crt | base64 | tr -d '\n')
kubectl patch validatingwebhookconfiguration kube-enforcer-admission-hook-config --type=json -p "[{\"op\":\"replace\",\"path\":\"/webhooks/0/clientConfig/caBundle\",\"value\":\"$CA\"}]"
kubectl patch mutatingwebhookconfiguration kube-enforcer-me-injection-hook-config --type=json -p "[{\"op\":\"replace\",\"path\":\"/webhooks/0/clientConfig/caBundle\",\"value\":\"$CA\"}]"
sed -i'.original' "s/caBundle.*/caBundle: $CA/g" aqua-csp-quick-hostpath.yaml
```

**Step 4. Restart KubeEnforcer.**

```SHELL
kubectl rollout restart deployment aqua-kube-enforcer -n aqua
```

## Access Aqua Enterprise console

**Step 1. Get the external IP of the console.**

```SHELL
kubectl get svc -n aqua
```

**Step 2. Get the external IP of the console, if Aqua Enterprise is deployed on Minikube.**

```SHELL
minikube tunnel
kubectl get svc -n aqua
```

**Step 3. Access aqua-web service from your browser using the url:**

```SHELL
http://<aqua-web service>:<aqua-web port>
```

## Troubleshooting to access Aqua Enterprise

If you did not define a default load-balancer for your Kubernetes cluster, aqua-web's public service IP status will remain frozen as "pending", after deploying through quick-start method. In this case, you can access Aqua Enterprise using a client-side kubectl tunnel. 

If load-balancer is not defined, to access Aqua Enterprise:

**Step 1. Use kubectl to get aqua-web’s cluster IP.**

```SHELL
kubectl get pods -n aqua
```

**Step 2. Use the kubectl port-forward command in a separate window to open the tunnel.**

```SHELL
kubectl port-forward -n aqua aqua-web <LOCAL_TUNNEL_PORT>:<AQUA_POD_CLUSTER_IP>
```

**Step 3. Access Aqua Enterprise from your browser using the url:**

```SHELL
http://localhost:<LOCAL_TUNNEL_PORT>
```