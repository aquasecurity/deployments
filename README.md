<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Product Deployment

## Overview

[Aqua Platform](https://www.aquasec.com/aqua-cloud-native-security-platform/) is a layered, full-lifecycle cloud native security platform that secures containerized, serverless, and VM-based applications, from application build, infrastructure through production runtime environments. Aqua runs either in SaaS or Self-Hosted Enterprise edition, at any scale.

 This is the repository for Aqua product deployment and explains different methods to deploy each Aqua components. It also explains quick-start deployment method which is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test. For this deployment method, refer to the [quick_start](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/quick_start) directory.

 Aqua components can be deployed on multiple platforms such as Kubernetes, AWS ECS, OpenShift, no-orchestrator, and more, using different deployment methods such as manifests, Helm, Operator, proprietary CLI tools, RPM, and scripts. Supporting deployment methods for each Aqua component is listed in the respective directory of the Aqua component.

## Aqua SaaS edition deployment

Most users use Aqua SaaS edition, which does not require building and operating an Aqua server in their datacenter. Aqua SaaS users should deploy Enforcers in their environments to enable runtime protection of various workloads. Following are the components that are available for Aqua SaaS users:
* [Enforcers](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers):  
  * Aqua Enforcer: Used for containers and host protection
  * KubeEnforcer: Used for full stack Kubernetes cluster protection 
  * VM Enforcer: Used for VM workloads protection
  * MicroEnforcer: Used for container runtime security which are running in Containers-as-a-Service (CaaS) environments
  * NanoEnforcer: Used for runtime protection of serverless functions
* [Scanner](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/scanner): Used to scan images, VMWare Tanzu applications, and serverless functions locally or stored in a registry

## Aqua Enterprise Self-Hosted edition deployment

Aqua Enterprise Self-Hosted edition requires deploying Aqua server and other components in your datacenter. Users that require a Self-Hosted Enterprise edition should first use the following server components to build the local server:
*  [Server](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/server): Includes the core server components – Console, Gateway, and Database. Deploying this component is mandatory for Aqua Self-Hosted edition. 
*  [Tenant Manager](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/tenant_manager) *(Optional)*: Component to manage multiple Aqua deployments from a single console
*  [CyberCenter](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/cyber_center): Component for air-gap environments

After the server is enabled, users can deploy the Enforcers and Scanners like SaaS users. Deployment of Enforcer and Scanner components for Aqua SaaS and Self-Hosted Enterprise is same as explained in this repository.

## Quick Start

A Quick Start option is available for small non-production deployments and quick evaluations. It deploys all of Aqua components, server and enforcers, in a single cluster. This method can be used to deploy Aqua platform on your Kubernetes cluster only.

## Deployment methods

You can deploy the mentioned Aqua components using one of the following methods:
* manifests
* operator
* Helm
* AWS Cloudformation
* Aquactl (Aqua CLI)
* RPM (for no-orchestrator environments)
* Scripts

Each Aqua component can be deployed through a few of the methods (not all) listed above. Applicability of deployment methods for each Aqua component is listed in the directories for the respective Aqua components in this repository.

Before you start using the deployment methods documented in this repository, Aqua strongly recommends you to refer the [Product documentation on Deployments](https://docs.aquasec.com/docs/deployment-overview).
