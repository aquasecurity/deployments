<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# KubeEnforcer

## Overview

The KubeEnforcer runs as a deployment and provides admission runtime security for Kubernetes workloads and infrastructure.

A single KubeEnforcer can be deployed on each Kubernetes cluster and uses native Kubernetes Admission Controller APIs to perform its functions, without the need for an Aqua Enforcer:

* [MutatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#mutatingadmissionwebhook): seamlessly applies security controls for deployments
* [ValidatingAdmissionWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#validatingadmissionwebhook) enforces Assurance Policies on newly deployed workloads

## Deployment methods
* [Manifests and Aquactl](./kubernetes_and_openshift/manifests)
* [Helm](./kubernetes_and_openshift/helm)
* [Operator](./kubernetes_and_openshift/operator)

## Supported platforms
* Kubernetes and Red Hat OpenShift

KubeEnforcers are supported on Linux platforms (with exception of VMware Tanzu TKGI).

## Suited for
* Aqua Platform SaaS Edition
* Aqua Platform Self-Hosted Edition

## References

Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends that you read the following product documentation:
* [Introduction to Enforcers](https://docs.aquasec.com/v2022.4/platform/runtime-protection/enforcers/enforcers-introduction/)
* [Types of Enforcers](https://docs.aquasec.com/v2022.4/platform/runtime-protection/enforcers/enforcers-types/)
* [Deployments Overview](https://docs.aquasec.com/v2022.4/platform/deployments/deployments-overview/)
* [Deploy KubeEnforcer: Overview](https://docs.aquasec.com/v2022.4/platform/deployments/deploy-enforcers/deploy-kubeenforcer-in-classic-mode/deploy-kubeenforcer-overview/)
