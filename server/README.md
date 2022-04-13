<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Server

## Overview
Server includes the following components:
* Console (Aqua UI)
* Gateway
* Database (Optional)

## Deployment methods
* [Manifests and Aquactl](./kubernetes_and_openshift/manifests)
* [Helm](./kubernetes_and_openshift/helm)
* [Operator](./kubernetes_and_openshift/operator)
* [AWS CloudFormation ECS-EC2](./ecs/cloudformation/aqua-ecs-ec2)
* [AWS CloudFormation ECS-Fargate](./ecs/cloudformation/aqua-ecs-fargate)

## Supported platforms
* Kubernetes and Openshift
* AWS ECS
* Docker

### Note: 
* For OpenShift version 3.x use RBAC definition from ./kubernetes_and_openshift/manifests/aqua_csp_002_RBAC/openshift_ocp3x 
* For OpenShift version 4.x use RBAC definition from ./kubernetes_and_openshift/manifests/aqua_csp_002_RBAC/openshift 

## Suited for
* Aqua Enterprise Self-Hosted edition

## References
Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the following product documentation:
* [Deploy Server Components](https://docs.aquasec.com/v6.5/docs/deploy-k8s-server-components) 
* [Kubernetes with Helm Charts](https://docs.aquasec.com/v6.5/docs/kubernetes-with-helm)
* [Deploy Aqua on Amazon Elastic Container Service (ECS)](https://docs.aquasec.com/v6.5/docs/amazon-elastic-container-service-ecs#section-step-1-deploy-the-aqua-server-gateway-and-database).