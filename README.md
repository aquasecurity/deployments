<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Product Deployment

This is the repository for Aqua product deployments.

[Aqua Security](https://www.aquasec.com/products/aqua-cloud-native-security-platform/) is a layered, full-lifecycle cloud native security platform that secures containerized, serverless, and VM-based applications, from application build, infrastructure through production runtime environments. Aqua runs either in SaaS or Self-Hosted Enterprise edition, at any scale.

You should deploy Aqua product using different Aqua components, through the required platforms such as Kuberneters, AWS Cloud Formation, Openshift, etc. 

Following are the different Aqua components that you should deploy as required, to start using Aqua SaaS edition:
* [Enforcers](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers): VM Enforcer, Kube Enforcer, Aqua Enforcer
* [Scanner](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/3_scanner)

Following are the different Aqua components that you should deploy as required in the order mentioned, to start using Aqua Self-Hosted Enterprise edition:
* [Server](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/1_server)
* [Enforcers](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/2_enforcers): VM Enforcer, Kube Enforcer, Aqua Enforcer
* [Scanner](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/3_scanner)
* [Tenant Manager](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/4_tenant_manager)
* [CyberCenter](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/5_CyberCenter)

This repository explains different methods to deploy Aqua components as mentioned above. It also explains quick-start deployment method which is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test.

Before you start using the deployment methods documented in this reposiory, Aqua strongly recommends you to refer the [product documentation on Deployments](https://docs.aquasec.com/docs/deployment-overview).

You can deploy the mentioned Aqua components using one of the following methods:
* manifests
* operator
* Helm
* AWS Cloudformation

Different deployment methods that are appliable to each Aqua component are organized in different folders in this repository.
