<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Enterprise Product Deployment

## Overview

[Aqua Platform](https://www.aquasec.com/aqua-cloud-native-security-platform/) is a layered, full-lifecycle cloud native security platform that secures containerized, serverless, and VM-based applications, from application build, infrastructure through production runtime environments. Aqua Enterprise runs either in SaaS or Self-Hosted edition, at any scale.

 This repository explains different methods to deploy each Aqua component. It also provides a [quick_start](./quick_start) deployment suited for proofs-of-concept (POCs), training, and test environemnts.

 Aqua components can be deployed on multiple platforms such as Kubernetes, AWS ECS, OpenShift, no-orchestrator, and more, using different deployment methods such as manifests, Helm, Operator, proprietary CLI tools, RPM, and scripts. Deployment resources for each Aqua component is listed in the respective directory.

### Aqua Enterprise SaaS edition deployment

Users working with Aqua Enterprise SaaS edition do not need to deploy Aqua server in their datacenter but only the relevant Enforcers to enable runtime protection. Following are the components that are available for Aqua SaaS users:
* [Enforcers](./enforcers):  
  * **Aqua Enforcer**: containers and host protection
  * **KubeEnforcer**: full stack Kubernetes cluster protection 
  * **VM Enforcer**: VM workloads protection
  * **MicroEnforcer**: runtime security for containers running in Containers-as-a-Service (CaaS) environments
  * **NanoEnforcer**: runtime protection of serverless functions
* [Scanner](./scanner): Used to scan images, VMWare Tanzu applications, and serverless functions locally or stored in a registry
* [Cloud Connector](./cloud_connector): the Aqua Cloud Connector establishes a secure connection to the Aqua Platform console, giving Aqua Platform remote access to resources on the local clusters.


### Aqua Enterprise Self-Hosted edition deployment

Aqua Enterprise Self-Hosted edition requires deploying Aqua server and other components in your datacenter. Following are the server components available for deployment:
*  [Server](./server): core server components – Console, Gateway, and Database. This deployment is mandatory for Aqua Self-Hosted edition. 
*  [Tenant Manager](./tenant_manager) *(Optional)*: manage multiple segregated Aqua deployments from a single console
*  [CyberCenter](./cyber_center): required for air-gap environments

After deploying Server components, you can deploy Enforcers and Scanners similar to SaaS users.

### Quick-start deployment

A quick-start option is available for small non-production deployments and quick evaluations. It deploys Aqua Server and all Enforcers, in a single Kubernetes cluster.

# Deployment methods

You can deploy the mentioned Aqua components using one of the following methods:
* Manifests
* Helm
* Operator
* AWS Cloudformation
* Aquactl (Aqua CLI)
* RPM (for no-orchestrator environments)
* Scripts

Each Aqua component can be deployed through a selection of the methods above, as listed in component's directory itself.

Before you start using the deployment methods in this repository, Aqua strongly recommends you to refer the [Product documentation on Deployments](https://docs.aquasec.com/v6.5/docs/deployment-overview).
