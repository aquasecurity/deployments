<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Scanner

### Overview
Aqua scanner performs scanning of the following objects for security issues:
* Container images
* VMware Tanzu applications
* Serverless Functions

### Deployment Methods
* [Manifests and Aquactl](./kubernetes_and_openshift/manifests/)
* [Helm](./kubernetes_and_openshift/helm/)
* [Operator](./kubernetes_and_openshift/operator/)
* [AWS CloudFormation on the EC2 clusters](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/scanner/ecs/cloudformation)
* [Docker Swarm](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/scanner/docker/swarm)

### Supported Platforms
* Docker
* ECS
* Kubernetes and Openshift

### Suitable for
* Aqua SaaS edition
* Aqua Self-Hosted Enterprise edition

### References
Before you start using any method to deploy Aqua scanner, Aqua strongly recommends you to refer the Product documentation, [Deploy Scanner(s)](https://docs.aquasec.com/docs/deploy-k8s-scanners) and [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm#section-step-2-deploy-the-aqua-server-database-gateway-and-scanner).