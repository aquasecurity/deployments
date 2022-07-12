<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# VM Enforcer

## Overview
VM Enforcers provide the enforcement and assurance for your hosts (VMs). It is required that you deploy a VM Enforcer on each host that you want to protect.

## Prerequisites

* **Linux:** [runC](https://www.docker.com/blog/runc/) container runtime environment
* **Windows:** No specific prerequisites required. It is available as a Windows service.

## Deployment methods

* [**Ansible Playbook**](./ansible/): for deploying VM Enforcer on a set of wide range of linux operating system VMs at a time
* [**Debian Package**](./deb/): for deploying VM Enforcer on one or more VMs using the Debian package
* [**RPM Package**](./rpm/): for deploying VM Enforcer on Red Hat based operating system which supports the `.rpm` packages
* [**Shell Script**](./shell/): for depoying VM Enforcer using script

## Suited for

* Aqua Enterprise SaaS
* Aqua Enterprise Self-Hosted

## Resources

* [VM Enforcer Overview](https://docs.aquasec.com/v6.5/docs/enforcers-overview#section-vm-enforcers)
* [Create a VM Enforcer Group and VM Enforcer](https://docs.aquasec.com/v6.5/docs/create-a-vm-enforcer-group-and-vm-enforcer)