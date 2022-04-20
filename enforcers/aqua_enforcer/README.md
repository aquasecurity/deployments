<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Enforcer 

## Overview

Aqua Enforcers provide full runtime protection and other functionality for containers and selected host-related functionality.

In Kubernetes, the enforcer runs as a DaemonSet deployment for workload runtime security, blocking unauthorized deployments, monitoring and restricting runtime activities and generating audit events.

## Deployment methods
* [Manifests and Aquactl](./kubernetes_and_openshift/manifests)
* [Helm](./kubernetes_and_openshift/helm)
* [Operator](./kubernetes_and_openshift/operator)
* [AWS CloudFormation ECS-EC2](./ecs/cloudformation/aqua-ecs-c2)

## Suited for
* Aqua Enterprise SaaS
* Aqua Enterprise Self-Hosted

## Supported platforms
* Kubernetes and Openshift (SaaS and Self-Hosted)
* AWS ECS (Self-Hosted only)
* Docker (SaaS and Self-Hosted)

### Note:
* For OpenShift version 3.x use RBAC definition from ./aqua_enforcer/kubernetes_and_openshift/manifests/001_aqua_enforcer_rbac/openshift_ocp3x
* For OpenShift version 4.x use RBAC definition from ./aqua_enforcer/kubernetes_and_openshift/manifests/001_aqua_enforcer_rbac/openshift


## References
Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the following product documentation:
* [Deploy Aqua Enforcer(s)](https://docs.aquasec.com/v6.5/docs/deploy-k8s-aqua-enforcers)
* [Kubernetes with Helm Charts](https://docs.aquasec.com/v6.5/docs/kubernetes-with-helm#section-step-4-deploy-the-aqua-enforcer)
* [Deploy Aqua on Amazon Elastic Container Service (ECS)](https://docs.aquasec.com/v6.5/docs/amazon-elastic-container-service-ecs#section-step-2-deploy-aqua-enforcers).
* [Enforcers Overview](https://docs.aquasec.com/v6.5/docs/enforcers-overview#section-aqua-enforcers) and [Aqua Enforcer](https://docs.aquasec.com/v6.5/docs/aqua-enforcer).