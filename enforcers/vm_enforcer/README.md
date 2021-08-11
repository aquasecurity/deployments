<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua VM Enforcers

### Overview
Deploy this component for enforcement and assurance functionality for hosts (VMs) and Kubernetes nodes.

This deployment leverages standard configuration management tools, Linux packaging formats and scripted installations.

### Deployment Methods
* [**Ansible Playbook**](./ansible/): deployment on a wide range of linux operating systems and hosts at a time, as defined in your Ansible inventory, using configuration management.
* [**RPM Package**](./rpm/): for Red Hat based operating systems which support `rpm` packages.
* [**Shell Script**](./shell/): scripted deployment.

### Suitable for
* Aqua SaaS edition
* Aqua Self-Hosted Enterprise edition