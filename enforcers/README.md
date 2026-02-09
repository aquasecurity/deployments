<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Enforcers

### Overview

Enforcers are the Aqua components that provide enforcement (securing your workloads and infrastructure during runtime) and other related functionality.

### Enforcer Types
These types of Enforcers can be deployed in Aqua:
* [Aqua Enforcer](./aqua_enforcer): full runtime protection and other functionality for containers, as well as selected host-related functionality
* [MicroEnforcer](./microenforcer): runtime security for containers running in Containers-as-a-Service (CaaS) environments, such as AWS Fargate and Microsoft Azure Container Instances (ACI)
* [KubeEnforcer](./kubeenforcer): runtime security and other support for your Kubernetes workloads and infrastructure. It can be deployed with advanced configuration and/or co-requisite Trivy-operator.
* [VM Enforcer](./vm_enforcer): enforcement and assurance functionality for hosts (VMs) and Kubernetes nodes.
* [Windows Enforcer](./windows_enforcer): full runtime protection for containers, as well as selected host-related functionality for Windows platforms.

### Suited for
* Aqua Platform SaaS Edition
* Aqua Platform Self-Hosted Edition

### References
For more information, see the product documentation:
* [Assurance and Enforcement](https://docs.aquasec.com/v2022.4/platform/overview-and-concepts/assurance-and-enforcement/)
* [Introduction to Enforcers](https://docs.aquasec.com/v2022.4/platform/runtime-protection/enforcers/enforcers-introduction/)
* [Types of Enforcers](https://docs.aquasec.com/v2022.4/platform/runtime-protection/enforcers/enforcers-types/)
* [Deployments Overview](https://docs.aquasec.com/v2022.4/platform/deployments/deployments-overview/)
