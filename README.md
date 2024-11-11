<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Enterprise Product Deployment

## Overview

[Aqua Platform](https://www.aquasec.com/aqua-cloud-native-security-platform/) is a layered, full-lifecycle cloud native security platform that secures containerized, serverless, and VM-based applications, from application build, infrastructure through production runtime environments. Aqua Enterprise runs either in SaaS or Self-Hosted edition, at any scale.

This repository explains different methods for deploying each Aqua Platform component. It also provides a [quick_start](./quick_start) deployment suited for proofs-of-concept (POCs), training, and test environemnts.

Aqua components can be deployed on multiple platforms such as Kubernetes, AWS ECS, OpenShift, no-orchestrator, and more, using different deployment methods such as manifests, Helm, Operator, proprietary CLI tools, RPM, and scripts. Deployment resources for each Aqua component are listed in the respective directories.

### Aqua Enterprise SaaS Edition deployment

Users working with Aqua Enterprise SaaS Edition do not need to deploy the Aqua Server in their data center. They need deploy only the required scanners and Enforcers to enable build-time and runtime protection, respectively. The following components are available for Aqua SaaS users:
* [Enforcers](./enforcers):  
  * **Aqua Enforcer**: container and host protection
  * **KubeEnforcer**: full-stack Kubernetes cluster protection 
  * **VM Enforcer**: VM workload protection
  * **MicroEnforcer**: runtime security for containers running in Containers-as-a-Service (CaaS) environments
  * **NanoEnforcer**: runtime protection of serverless functions
* [Scanner](./scanner): Used to scan images, VMware Tanzu applications, and serverless functions locally or stored in a registry
* [Aqua Cloud Connector](./cloud_connector): Establishes a secure connection to the Aqua Platform console, giving Aqua Platform remote access to resources on local clusters


### Aqua Enterprise Self-Hosted Edition deployment

Aqua Enterprise Self-Hosted Edition requires deploying the Aqua Server and other components in your data center. These Aqua Platform components are available for deployment:
*  [Server](./server): core server components (Console, Gateway, and Database). Deployment of the Console and Gateway are mandatory; deployment of the Database is optional. 
*  [CyberCenter](./cyber_center): required for air-gapped environments
*  [Tenant Manager](./tenant_manager) (optional): manages multiple segregated Aqua deployments from a single console

After deploying Server components, you can deploy Enforcers and Scanners in a manner that is similar to SaaS users.

# Deployment methods

You can deploy the Aqua Platform components using one of the following methods:
* Manifests
* Helm
* Operator
* AWS CloudFormation
* Aquactl (Aqua CLI)
* RPM (for no-orchestrator environments)
* Scripts

Each Aqua component can be deployed through a selection of the methods above, as listed in component's directory itself.

Before you start using the deployment methods in this repository, we strongly recommend that you to refer to the official product documentation:
* [Aqua Environment and Configuration](https://docs.aquasec.com/v2022.4/platform/aqua-environment-and-configuration/aqua-env-and-config-purpose-of-this-section/)
* [Deployments]([https://docs.aquasec.com/docs/deployment-overview](https://docs.aquasec.com/v2022.4/platform/deployments/))
