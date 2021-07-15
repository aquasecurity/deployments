# Overview

Aqua enforcer provides full runtime protection and other functionality for containers, as well as selected host-related functionality. The Aqua enforcer, running as a DaemonSet deployment, provides runtime security for your Kubernetes workloads by blocking unauthorized deployments, monitoring and restricting runtime activities, and generating audit events for your review. Aqua enforcer is supported on the Linux and Windows platforms. Deployment of Aqua enforcer is optional. A single Aqua Enforcer can be deployed per Kubernetes node (or non-Kubernetes host). For more information, refer the product documentation, [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview#section-aqua-enforcers) and [Aqua Enforcer](https://docs.aquasec.com/docs/aqua-enforcer).

You can deploy the Aqua enforcer component using one of the following methods:
* manifests
* operator
* Helm
* AWS CloudFormation on the ECS and EC2 clusters 

Details of each deployment method is explained in the respective directory shown above. Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the product documentation, [Deploy Aqua Enforcer(s)](https://docs.aquasec.com/docs/deploy-k8s-aqua-enforcers), [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm#section-step-4-deploy-the-aqua-enforcer), and [Deploy Aqua on Amazon Elastic Container Service (ECS)](https://docs.aquasec.com/docs/amazon-elastic-container-service-ecs#section-step-2-deploy-aqua-enforcers).