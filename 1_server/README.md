<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Overview

The Aqua server component includes the Server itself, its UI (console), the Aqua Gateway, and database (DB). This repository explains all the deployments methods for Aqua Server component on the platforms such as Kuberneters, AWS CloudFormation, Openshift, etc. 

You can deploy the Server component using one of the following methods:
* manifests
* operator
* Helm
* AWS CloudFormation on the ECS, EC2, and Fargate clusters

Details of each deployment method is explained in the respective directory shown above. Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the product documentation, [Deploy Server Components](https://docs.aquasec.com/docs/deploy-k8s-server-components), [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm), and [Deploy Aqua on Amazon Elastic Container Service (ECS)](https://docs.aquasec.com/docs/amazon-elastic-container-service-ecs#section-step-1-deploy-the-aqua-server-gateway-and-database)