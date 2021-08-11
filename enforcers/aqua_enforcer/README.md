# Aqua Enforcer 

### Overview

Aqua Enforcers provide full runtime protection and other functionality for containers and selected host-related functionality.

In Kubernetes, the enforcer runs as a DaemonSet deployment for workload runtime security, blocking unauthorized deployments, monitoring and restricting runtime activities and generating audit events.

### Deployment Methods
* [Manifests and Aquactl](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/aqua_enforcer/kubenetes_and_openshift/manifests)
* [Helm](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/aqua_enforcer/kubenetes_and_openshift/helm)
* [Operator](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/aqua_enforcer/kubenetes_and_openshift/operator)
* [AWS CloudFormation](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/aqua_enforcer/ecs/cloudformation) for ECS and EC2 clusters 

### Supported Platforms
* Docker
* ECS
* Kubernetes and Openshift

### References
Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the product documentation, [Deploy Aqua Enforcer(s)](https://docs.aquasec.com/docs/deploy-k8s-aqua-enforcers), [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm#section-step-4-deploy-the-aqua-enforcer), and [Deploy Aqua on Amazon Elastic Container Service (ECS)](https://docs.aquasec.com/docs/amazon-elastic-container-service-ecs#section-step-2-deploy-aqua-enforcers).

For the product documentation, [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview#section-aqua-enforcers) and [Aqua Enforcer](https://docs.aquasec.com/docs/aqua-enforcer).