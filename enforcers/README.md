# Enforcers Deployment

Aqua enforcement secures your workloads and infrastructure during runtime. Enforcers are the Aqua components that implement enforcement-related and other functionality. For more information on the Aqua enforcers, refer the product documentation, [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview) and [Assurance and Enforcement Overview](https://docs.aquasec.com/docs/assurance-and-enforcement-overview).

This repository explains different enforcers that can be deployed while setting up your Aqua product. This repository has directory for each enforcer to explain different deployments methods, on the platforms such as Kuberneters, AWS CloudFormation, Openshift, so on.

Following are the enforcers that can be deployed as part of Aqua product deployment:
* [Aqua Enforcer](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/aqua_enforcer): provides full runtime protection for containers, as well as selected host-related functionality.
* [Kube Enforcer](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer): provides runtime security for your Kubernetes workloads and infrastructure. It can be deployed with advanced configuration and/or co-requisite Starboard.
* [VM Enforcer](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/vm_enforcer): provides Host enforcement and assurance functionality for hosts (VMs). A single VM Enforcer can be deployed per Kubernetes node (or non-Kubernetes host / VM).

You can deploy the required enforcers from the list, for both the Aqua SaaS and Self-Hosted Enterprise editions. For the procedures on deployment methods for each enforcer, navigate to the respective directory above.