<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Product Deployment

## Overview

[Aqua Security](https://www.aquasec.com/products/aqua-cloud-native-security-platform/) is a layered, full-lifecycle cloud native security platform that secures containerized, serverless, and VM-based applications, from application build, infrastructure through production runtime environments. Aqua runs either in SaaS or Self-Hosted Enterprise edition, at any scale.

 Aqua components can be deployed on multiple platforms such as Kuberneters, ECS, OpenShift, no-orchestrator, and more, using different deployment methods such as manifests, helm, operator, proprietary cli tools, RPM, and scripts.

 This is the repository for Aqua product deployments. This repository explains different methods to deploy Aqua components as mentioned above. It also explains quick-start deployment method which is suited for proofs-of-concept (POCs) and environments intended for instruction, development, and test. For this deployment method, refer the [quick_start](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/quick_start) directory.

## Aqua SaaS edition deployment

Most users use Aqua SaaS edition, which relieve the user from building and operating an Aqua server in their datacenter. Aqua SaaS users need to deploy Enforcers in their environments to enable runtime protection of various workloads. However, there are a few more components that are available for Aqua SaaS users.
Following are the different Aqua components that you should deploy as required, to start using Aqua SaaS edition:
* [Enforcers](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers):  
  * Aqua Enforcer: Used for containers and host protection
  * Kube Enforcer: Used for full stack Kubernetes cluster protection 
  * VM Enforcer: Used for VM workloads protection
  * Micro Enforcer: Used for contrarians’ protection when there is no access to the host
  * Nano Enforcer: Used for Functions protection
* [Scanner](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/scanner): Used to scan local repositories with no access to the SaaS instance

## Aqua Self-Hosted edition deployment

Users that require a Self-Hosted Enterprise edition should first use the following server components to build the local server:
*  [Server](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/server): Includes the core server components – database, console, and gateway
*  [Tenant Manager](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/tenant_manager) *(Optional)*: Component to manage multiple Aqua deployments from a single console
*  [CyberCenter](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/cyber_center): Component for air-gap environments 

## Quick Start

A Quick Start option is avilable for small non-production deployments and quick evaluations. It is a one-click tool to deploy all of Aqua components, server and enforcers, in a single cluster for non-production usage.

## Deployment methods

You can deploy the mentioned Aqua components using one of the following methods:
* manifests
* operator
* Helm
* AWS Cloudformation
* Aquactl (Aqua CLI)
* RPM (for no-orchestrator environments)
* Scripts

Different deployment methods that are appliable to each Aqua component are organized in different directories in this repository.

Before you start using the deployment methods documented in this repository, Aqua strongly recommends you to refer the [Product documentation on Deployments](https://docs.aquasec.com/docs/deployment-overview).
