<img src="https://avatars3.githubusercontent.com/u/12783832?s=200&v=4" height="100" width="100" />

# Aqua KubeEnforcer Types

The KubeEnforcer runs as a deployment and provides admission runtime security for Kubernetes workloads and infrastructure. 

KubeEnforcer can be deployed in combination with co-requisite Starboard and/or advanced deployment for Pod Enforcer injection. Kube Enforcer(s) can be deployed manually with one of the following combinations per your requirement:

* [KubeEnforcer](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube-enforcer): provides runtime security for your Kubernetes workloads and infrastructure.
* [KubeEnforcer Advanced](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer_advanced): is a method of deploying Aqua KubeEnforcer in a special advanced configuration for Pod Enforcer injection.
* [KubeEnforcer Starboard](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer_starboard): Starboard is an Aqua Security open-source tool that increases the effectiveness of Kubernetes security. Starboard is deployed by default, when you deploy KubeEnforcer to assess workload compliance throughout the lifecycle of the workloads.
* [KubeEnforcer Advanced Starboard](https://github.com/KoppulaRajender/deployments/tree/6.5_dev/enforcers/kube_enforcer/kubernetes_and_openshift/manifests/kube_enforcer_advanced_starboard): is the Aqua KubeEnforcer component with Starboard capability deployed in a special advanced configuration.

Navigate to the relevant directory (hyperlinked above) to know more about each KubeEnforcer component and its deployment method using manifest yaml files.