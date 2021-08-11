## Aqua Scanner Overview
Aqua scanner performs scanning of the following objects for security issues:

* Container images
* VMware Tanzu applications
* Serverless Functions

You can deploy Aqua scanner on both the Aqua SaaS and Self-Hosted Enterprise editions using one of the following methods:

* [Manifests and Aquactl](./kubernetes_and_openshift/manifests/)
* [Operator](./kubernetes_and_openshift/operator/)
* [Helm](./kubernetes_and_openshift/helm/)
* [AWS CloudFormation on the EC2 clusters](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/scanner/ecs/cloudformation)
* [Docker Swarm](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/scanner/docker/swarm)

Details of each deployment method is explained in the respective directory shown above. Before you start using any method to deploy Aqua scanner, Aqua strongly recommends you to refer the Product documentation, [Deploy Scanner(s)](https://docs.aquasec.com/docs/deploy-k8s-scanners) and [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm#section-step-2-deploy-the-aqua-server-database-gateway-and-scanner).