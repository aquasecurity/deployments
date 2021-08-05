## Aqua Scanner Overview
Aqua scanner scans the following types of objects for security issues:

* Container images
* VMware Tanzu applications
* Serverless Functions

Scanner registers container images with Aqua and imports results of scans already performed. You can deploy Aqua Scanner on both the Aqua SaaS and Self-Hosted Enterprise editions using one of the following methods:

* [manifests and Aquactl](./kubernetes_and_openshift/manifests/)
* [operator](./kubernetes_and_openshift/operator/)
* [Helm](./kubernetes_and_openshift/helm/)
* [AWS CloudFormation on the EC2 clusters](./scanner/ecs/cloudformation/)
* [docker swarm](./scanner/docker/swarm/)

Details of each deployment method is explained in the respective directory shown above. Before you start using any of the deployment methods documented in this repository, Aqua strongly recommends you to refer the Product documentation, [Deploy Scanner(s)](https://docs.aquasec.com/docs/deploy-k8s-scanners) and [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm#section-step-2-deploy-the-aqua-server-database-gateway-and-scanner).