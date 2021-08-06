## Deploy Aqua Scanner using Helm

Aqua scanner scans container images, VMware Tanzu applications, and serverless functions for security issues such as vulnerabilities, sensitive data, and malware. Scanner registers container images with Aqua and imports results of scans already performed. For more information, refer to the product documentation, [Aqua Scanner Overview](https://docs.aquasec.com/docs/aqua-scanner). 

Aqua Scanner can be deployed on both the Aqua SaaS and Self-Hosted Enterprise editions on your Kubernetes cluster, using the [Helm package manager](https://helm.sh/). To deploy Aqua Scanner using Helm charts, use artifacts and refer deployment instructions from the [Aqua Security Helm repository on GitHub](https://github.com/aquasecurity/aqua-helm/). Ensure that you use the latest branch of the Aqua Security Helm repository.

For detailed information, Aqua recommends you read the Product documentation, [Kubernetes with Helm Charts](https://docs.aquasec.com/docs/kubernetes-with-helm).