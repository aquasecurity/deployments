<img src="https://www.aquasec.com/wp-content/uploads/2016/05/aqua_logo_fullcolor.png" heigth="89" width="246" />

# Aqua Security Deployment Integrations

[Aqua Security](https://www.aquasec.com) deployment repository.

## Navigation and description

* [**Automation**](automation/) - Contains deployment code for Aqua CSP
    * [**Ansible**](automation/ansible/) - ***Comming Soon*** - Ansible playbooks and roles to deploy aqua container security platform (CSP) on your servers.
    * [**Bash**](automation/bash/) - Bash scripts to deploy aqua container security platform (CSP) on your servers. 
    * [**Terraform**](automation/terraform/) - ***Comming Soon*** - Terraform templates for provisioning your servers in cloud and etc, for deploying aqua container security platform (CSP).
* [**Cloud**](cloud/) - Aqua CSP Templates and deployments in public clouds.
    * [**AWS**](cloud/aws/) - AWS deployment with CloudFormation templates ,Terraform and etc.
    * [**Azure**](cloud/azure/) - Microsoft Azure deployment with Templates and etc.
    * [**GCP**](cloud/gcp/) - Google GCP deployment with marketplace helm and etc.
* [**Orchestrators**](orchestrators/) - Deploy Aqua container security platform (CSP) on docker orchestrators
    * [**DC/OS**](orchestrators/dcos/) - Deploy Aqua CSP on Mesosphere DC/OS.
    * [**Kubernetes**](orchestrators/kubernetes/) - Deploy Aqua CSP on Kubernetes with Helm or Templates and etc.
    * [**Nomad**](orchestrators/nomad/) - Deploy Aqua CSP on Nomad.
    * [**Openshift**](orchestrators/openshift/) - Deploy Aqua CSP on Openshift with templates.

## CI Plugins

* **Jenkins** - [*Aqua Security Scanner Plugin*](https://github.com/jenkinsci/aqua-security-scanner-plugin), Adds a Build Step for scanning Docker images, local or hosted on registries, for security vulnerabilities, using the API provided by Aqua Security.
* **Bamboo** - [*Aqua Security Scanner Bamboo*](https://marketplace.atlassian.com/apps/1216895/container-security?hosting=server&tab=overview) Vulnerability scanner for container images for Atlassian Bamboo.
* **VSTS** - [*Container Security For VSTS*](https://marketplace.visualstudio.com/items?itemName=aquasec.aquasec) Microsoft VSTS users can integrate with Aqua’s continuous image assurance, which is the most comprehensive, automated solution on the market for scanning and locking down container images, with deep scanning of container layers for vulnerabilities, and persistent controls to assure image integrity throughout its lifecycle.
* **CircleCI** - [*CircleCI Orb MicroScanner*](https://github.com/aquasecurity/circleci-orb-microscanner) Enables scanning of docker builds in CircleCi for OS package vulnerabilities.

##### Aqua Security CI/CD Blogs

* [*10 Essentials Container CI/CD Tools*](https://blog.aquasec.com/10-essential-container-ci/cd-tools) 

## Open Source Tools
* [**kube-bench**](https://github.com/aquasecurity/kube-bench) - The Kubernetes Bench for Security is a Go application that checks whether Kubernetes is deployed according to security best practices.
* [**kube-hunter**](https://github.com/aquasecurity/kube-hunter) - Hunt for security weaknesses in Kubernetes clusters.
* [**MicroScanner**](https://github.com/aquasecurity/microscanner) - Scan your container images for package vulnerabilities with Aqua Security.

## Issues and feedback
If you come across any problems or would like to give us feedback on deployments we encourage you to raise issues here on GitHub.

