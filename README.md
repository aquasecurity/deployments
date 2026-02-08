<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua Platform Product Deployment

## Overview

[Aqua Platform](https://www.aquasec.com/aqua-cloud-native-security-platform/) is a layered, full-lifecycle cloud native security platform that secures containerized, serverless, and VM-based applications, from application build, infrastructure through production runtime environments. Aqua Platform is provided in both SaaS or Self-Hosted Editions, and runs at any scale.

This repository explains different methods for deploying each Aqua component.

Aqua components can be deployed on multiple platforms such as Kubernetes, AWS ECS, Red Hat OpenShift, and no-orchestrator, using different deployment methods such as manifests, Helm charts, Operators, proprietary CLI tools, RPM, and scripts. Deployment resources for each Aqua component are listed in the respective directories.

### Aqua Platform SaaS Edition deployment

Users working with Aqua Platform SaaS Edition do not need to deploy an Aqua server in their datacenter; they need to deploy only the relevant components to enable build and runtime protection. Aqua SaaS Edition users can deploy these Enforcers:
* [Enforcers](./enforcers):  
  * **Aqua Enforcer**: full runtime protection for containers, as well as selected host-related functionality.
  * **KubeEnforcer**: runtime security for your Kubernetes workloads and infrastructure. It can be deployed with advanced configuration and/or co-requisite Trivy-operator. 
  * **VM Enforcer**: enforcement and assurance functionality for hosts (VMs) and Kubernetes nodes.
  * **MicroEnforcer**: runtime security for containers running in Containers-as-a-Service (CaaS) environments, such as AWS Fargate and Microsoft Azure Container Instances (ACI).
  * **NanoEnforcer**: runtime protection of AWS Lambda serverless function.
* [Scanners](./scanner): Used to scan images, VMWare Tanzu applications, and serverless functions locally or stored in a registry
* [Cloud Connector](./cloud_connector): The Aqua Cloud Connector is no longer required for private image registry integrations; the functionalities previously handled by the Cloud Connector are now directly managed by the Aqua SaaS scanners. However, the Cloud Connector may still be needed for other integrations, such as on-premises ServiceNow, Splunk, and other third-party tools. When deployed on local clusters, i.e., clusters on which Aqua Platform is not deployed, the Cloud Connector establishes a secure connection to the Aqua Server, providing access to resources on local clusters. 


### Aqua Enterprise Self-Hosted edition deployment

Aqua Enterprise Self-Hosted edition requires deploying Aqua server and other components in your datacenter. Following are the server components available for deployment:
*  [Server](./server): core server components – Console, Gateway, and Database. This deployment is mandatory for Aqua Self-Hosted edition. 
*  [CyberCenter](./cyber_center): required for air-gapped environments

After deploying Server components, you can deploy Enforcers and Scanners similar to SaaS users.

# Deployment methods

You can deploy the mentioned Aqua components using one or more of the following methods:
* Manifests
* Helm charts
* Operator
* AWS CloudFormation
* RPM (for no-orchestrator environments)
* Scripts
* Aquactl (Aqua CLI)

Each Aqua component can be deployed through a selection of the methods above, as listed in component's directory itself.

Before you start using any of the deployment methods documented in this reposiory, Aqua strongly recommends that you read the following product documentation:
* [Introduction to Enforcers](https://docs.aquasec.com/v2022.4/platform/runtime-protection/enforcers/enforcers-introduction/)
* [Types of Enforcers](https://docs.aquasec.com/v2022.4/platform/runtime-protection/enforcers/enforcers-types/)
* [Deployments Overview](https://docs.aquasec.com/v2022.4/platform/deployments/deployments-overview/)
* [Deploy KubeEnforcer: Overview](https://docs.aquasec.com/v2022.4/platform/deployments/deploy-enforcers/deploy-kubeenforcer-in-classic-mode/deploy-kubeenforcer-overview/)
