## Overview

The KubeEnforcer runs as single replica deployment and provides runtime security for your Kubernetes workloads and infrastructure. KubeEnforcers are supported on Linux platforms (with exception of VMware Tanzu TKGI). A single KubeEnforcer can be deployed on each Kubernetes cluster. As the name implies, KubeEnforcers support Kubernetes-specific functionality to perform its functions, without the need for an Aqua Enforcer. For more information, refer to [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview#section-kube-enforcers)

It uses native Kubernetes Admission Controller APIs:
* [MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook) seamlessly applies security controls to the applications in the cluster.
* [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) enforces Assurance Policies on newly deployed workloads.

You can deploy the KubeEnforcer component using one of the following methods:
* [manifests](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/manifests)
* [operator](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/operator)
* [Helm](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers/kube_enforcer/Helm) 

Details of each deployment method is explained in the respective directory shown above. Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the product documentation, [Deploy Kube Enforcer(s)](https://docs.aquasec.com/docs/deploy-k8s-aqua-kubeenforcers), [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm#section-step-4-deploy-the-aqua-enforcer). /need to confirm whether Helm deployment is applicable to KE and find the Product Doc to refer./