## Quick-start deployment of Aqua Enterprise using Helm

The quick-start deployment can be used to deploy Aqua Self-Hosted Enterprise on your Kubernetes cluster quickly and easily. It is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test but not for production environments.

For production usage, enterprise-grade deployments, advanced use cases, and deployment on other Kubernetes platforms, deploy Aqua Enterprise with the required Aqua components (such as server, enforcers, scanner, so on.) on your orchestration platform. For more information, refer to the Product documentation, [Deploy Aqua Enterprise](https://docs.aquasec.com/docs/deployment-overview).

The quick-start deployment supports the following Kubernetes platforms:
* Kubernetes
* AKS (Microsoft Azure Kubernetes Service)
* EKS (Amazon Elastic Kubernetes Service)
* GKE (Google Kubernetes Engine)

To deploy Aqua Enterprise through Quick-start deployment method using Helm charts, use artifacts and refer deployment instructions from the [Aqua Security Helm repository on GitHub](https://github.com/aquasecurity/aqua-helm/). Ensure that you use the latest branch of the Aqua Security Helm repository.