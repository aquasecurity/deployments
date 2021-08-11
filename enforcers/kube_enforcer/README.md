# Aqua Kube Enforcer

### Overview

The KubeEnforcer runs as a deployment and provides adminission runtime security for Kubernetes workloads and infrastructure.

 A single KubeEnforcer can be deployed on each Kubernetes cluster and uses native Kubernetes Admission Controller APIs to perform its functions, without the need for an Aqua Enforcer:

* [MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook): seamlessly applies security controls for deployments
* [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) enforces Assurance Policies on newly deployed workloads

### Deployment Methods
* [Manifests and Aquactl](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer/kubenetes_and_openshift/manifests)
* [Helm](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer/kubenetes_and_openshift/helm)
* [Operator](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer/kubenetes_and_openshift/operator)

### Supported Platforms
* Kubernetes and Openshift

KubeEnforcers are supported on Linux platforms (with exception of VMware Tanzu TKGI).

### References

Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the product documentation, [Deploy Kube Enforcer(s)](https://docs.aquasec.com/docs/deploy-k8s-aqua-kubeenforcers).

For more information about all Enforcers refer to [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview#section-kube-enforcers).