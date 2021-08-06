## Deploy Aqua Scanner using Operator

The aqua-operator is a group of controllers that runs within your OpenShift cluster. It supports to deploy and manage an Aqua Security cluster and components, including Aqua Scanner.

You can use the aqua-operator to:
* Deploy Aqua Enterprise components in the OpenShift clusters
* Scale up Aqua Enterprise components with extra replicas
* Assign metadata tags to Aqua Enterprise components
* Scale the number of Aqua Scanners automatically based on the number of images in the scan queue

Aqua scanner scans container images, VMware Tanzu applications, and serverless functions for security issues such as vulnerabilities, sensitive data, and malware. Scanner registers container images with Aqua and imports results of scans already performed. For more information, refer to the product documentation, [Aqua Scanner Overview](https://docs.aquasec.com/docs/aqua-scanner). 

Aqua Scanner can be deployed for both the Aqua SaaS and Self-Hosted Enterprise editions on your Kubernetes cluster. To deploy Aqua Scanner using the aqua-operator, use artifacts and refer deployment instructions from the [Aqua Security Operator repository on GitHub](https://github.com/aquasecurity/aqua-operator).
