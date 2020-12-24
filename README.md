<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Security Deployments and Integrations

This is the repository for [Aqua Security](https://www.aquasec.com) product deployments and integrations.

## Deployment of Aqua Enterprise

[Aqua Enterprise](https://www.aquasec.com/products/aqua-cloud-native-security-platform/) is a layered, full-lifecycle cloud native security platform that secures containerized, serverless and VM-based applications, from CI/CD pipelines to production runtime environments. Aqua Enterprise runs on-prem or in the cloud, at any scale.

* [**Orchestrators**](orchestrators/)
    * [**Kubernetes**](orchestrators/kubernetes/)
    * [**Mesosphere DC/OS**](orchestrators/dcos/)
    * [**Red Hat OpenShift**](orchestrators/openshift/)
    * [**Pivotal Container Service (PKS)**](orchestrators/pks/)
    * [**Rancher Kubernetes Engine**](orchestrators/rancher/)
    
* [**Cloud Provider Platforms**](cloud/)
    * [**AWS**](cloud/aws/)
    * [**Amazon Elastic Kubernetes Service (EKS)**](orchestrators/eks/)
    * [**Google Kubernetes Engine (GKE)**](orchestrators/gke/)
    * [**Google Cloud Platform (GCP)**](cloud/gcp/) 
    * [**Microsoft Azure**](cloud/azure/)
    * [**Microsoft Azure Kubernetes Service (AKS)**](orchestrators/aks/) 

## CI Plugins

* **Bamboo** - [*Aqua Security Scanner Bamboo*](https://marketplace.atlassian.com/apps/1216895/container-security?hosting=server&tab=overview) - Vulnerability scanner for container images for Atlassian Bamboo.
* **Jenkins** - [*Aqua Security Scanner Jenkins Plugin*](https://github.com/jenkinsci/aqua-security-scanner-plugin) - Adds a Build Step for scanning Docker images, local or hosted on registries, for security vulnerabilities, using the API provided by Aqua Security.
* **Microsoft VSTS** - [*Container Security For VSTS*](https://marketplace.visualstudio.com/items?itemName=aquasec.aquasec) - Microsoft VSTS users can integrate with Aqua’s continuous image assurance, which is the most comprehensive, automated solution on the market for scanning and locking down container images, with deep scanning of container layers for vulnerabilities, and persistent controls to assure image integrity throughout its lifecycle.

## Open Source Tools

* [**Kube-bench**](https://github.com/aquasecurity/kube-bench) - [Kube-bench](https://blog.aquasec.com/announcing-kube-bench-an-open-source-tool-for-running-kubernetes-cis-benchmark-tests) is a Go application that runs the [CIS Benchmark for Kubernetes](https://www.cisecurity.org/benchmark/kubernetes/). You can run it on each of your nodes to compare your deployment with the best-practices security guidelines from the CIS community.
* [**Kube-hunter**](https://github.com/aquasecurity/kube-hunter) - [Kube-hunter](https://blog.aquasec.com/kube-hunter-kubernetes-penetration-testing) probes your Kubernetes cluster for security issues; it's like automated penetration testing.
* [**MicroScanner**](https://github.com/aquasecurity/microscanner) - The [MicroScanner](https://blog.aquasec.com/microscanner-free-image-vulnerability-scanner-for-developers) scans your container images for package vulnerabilities. The MicroScanner uses the same vulnerability database as Aqua Security’s best-in-class commercial scanner, so you get top-notch results.

## Automation

[**Automation**](automation/) - Contains deployment code for Aqua Enterprise
* [**Shell**](automation/shell/) - Shell scripts for deploying Aqua Enterprise on your servers
* [**Aquactl**](automation/aquactl/) - Aqua command line for deploying Aqua Enterprise components and managing Aqua Enterprise

## Aqua Security CI/CD Blogs

* [*10 Essential Container CI/CD Tools*](https://blog.aquasec.com/10-essential-container-ci/cd-tools) 

## Feedback

For all feedback related to deployments -- problems, suggestions, etc. -- we encourage you to raise issues here on GitHub.
