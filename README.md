<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Security Deployment Integrations

[Aqua Security](https://www.aquasec.com) deployment repository.

## Navigation and description

* [**Automation**](automation/) - Contains deployment code for Aqua Container Security Platform (CSP)
    * [**Shell**](automation/shell/) - Shell scripts to deploy Aqua Container Security Platform (CSP) on your servers. 
    * [**Aquactl**](automation/aquactl/) - Aqua Command line for deploy aqua components and manage aqua
* [**Cloud**](cloud/) - Aqua Container Security Platform (CSP) templates and deployments in public clouds.
    * [**AWS**](cloud/aws/) - AWS deployment with CloudFormation templates, Terraform, etc.
    * [**Azure**](cloud/azure/) - Microsoft Azure deployment with templates, etc.
    * [**GCP**](cloud/gcp/) - Google GCP deployment with Marketplace, Helm, etc.
* [**Orchestrators**](orchestrators/) - Deploy Aqua Container Security Platform (CSP) on Docker orchestrators
    * [**Kubernetes**](orchestrators/kubernetes/) - Deploy Aqua Container Security Platform (CSP) on Kubernetes with Helm, templates, etc.
    * [**Mesosphere DC/OS**](orchestrators/dcos/) - Deploy Aqua Container Security Platform (CSP) on Mesosphere DC/OS.
    * [**Red Hat OpenShift**](orchestrators/openshift/) - Deploy Aqua Container Security Platform (CSP) on Red Hat OpenShift.
    * [**Google Kubernetes Engine**](orchestrators/gke/) - Deploy Aqua Container Security Platform (CSP) on Google Kubernetes Engine (GKE).
    * [**Microsoft Azure Kubernetes Service**](orchestrators/aks/) - Deploy Aqua Container Security Platform (CSP) on Azure Kubernetes Service (AKS).
    * [**Amazon Elastic Kubernetes Service**](orchestrators/eks/) - Deploy Aqua Container Security Platform (CSP) on Elastic Kubernetes Service (EKS).
    * [**Pivotal Container Service**](orchestrators/pks/) - Deploy Aqua Container Security Platform (CSP) on Pivotal Container Service (PKS).
    * [**Rancher Kubernetes Engine**](orchestrators/rancher/) - Deploy Aqua Container Security Platform (CSP) on Rancher Kubernetes Engine (RKE) with templates.

## CI Plugins

* **Jenkins** - [*Aqua Security Scanner Plugin*](https://github.com/jenkinsci/aqua-security-scanner-plugin) - Adds a Build Step for scanning Docker images, local or hosted on registries, for security vulnerabilities, using the API provided by Aqua Security.
* **Bamboo** - [*Aqua Security Scanner Bamboo*](https://marketplace.atlassian.com/apps/1216895/container-security?hosting=server&tab=overview) - Vulnerability scanner for container images for Atlassian Bamboo.
* **CircleCI** - [*CircleCI Orb MicroScanner*](https://github.com/aquasecurity/circleci-orb-microscanner) - Enables scanning of Docker builds in CircleCi for OS package vulnerabilities.
* **VSTS** - [*Container Security For VSTS*](https://marketplace.visualstudio.com/items?itemName=aquasec.aquasec) - Microsoft VSTS users can integrate with Aqua’s continuous image assurance, which is the most comprehensive, automated solution on the market for scanning and locking down container images, with deep scanning of container layers for vulnerabilities, and persistent controls to assure image integrity throughout its lifecycle.

##### Aqua Security CI/CD Blogs

* [*10 Essential Container CI/CD Tools*](https://blog.aquasec.com/10-essential-container-ci/cd-tools) 

## Open Source Tools
* [**kube-bench**](https://github.com/aquasecurity/kube-bench) - The Kubernetes Bench for Security is a Go application that checks whether Kubernetes is deployed according to security best practices.
* [**kube-hunter**](https://github.com/aquasecurity/kube-hunter) - Hunts for security weaknesses in Kubernetes clusters.
* [**MicroScanner**](https://github.com/aquasecurity/microscanner) - Scans your container images for package vulnerabilities.

## Issues and feedback
If you encounter any problems or would like to give us feedback on deployments, we encourage you to raise issues here on GitHub.
