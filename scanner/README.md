<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Scanner

## Overview
Aqua scanner performs scanning of the following objects for security issues:
* Container images
* VMware Tanzu applications
* Serverless Functions

## Deployment methods
* [Manifests and Aquactl](./kubernetes_and_openshift/manifests/)
* [Helm](./kubernetes_and_openshift/helm/)
* [Operator](./kubernetes_and_openshift/operator/)
* [AWS CloudFormation on EC2 clusters](./ecs/cloudformation/aqua-ecs-ec2)

## Suited for
* Aqua Enterprise SaaS
* Aqua Enterprise Self-Hosted

## Supported platforms
* Kubernetes and Openshift (SaaS and Self-Hosted)
* AWS ECS (Self-Hosted only)
* Docker (SaaS and Self-Hosted)

## References
Before you start using any method to deploy Aqua scanner, Aqua strongly recommends you to refer the Product documentation:
* [Deploy Scanner(s)](https://docs.aquasec.com/v6.5/docs/deploy-k8s-scanners)
* [Kubernetes with Helm Charts](https://docs.aquasec.com/v6.5/docs/kubernetes-with-helm#section-step-2-deploy-the-aqua-server-database-gateway-and-scanner).