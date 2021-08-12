## Deploy KubeEnforcer using Helm

You can deploy KubeEnforcer for both the Aqua SaaS and Self-Hosted Enterprise editions in your Kubernetes cluster, using the [Helm charts](https://helm.sh/). KubeEnforcer can be deployed on the same cluster as the Aqua Server or on a different cluster, as per configuration. KubeEnforcer can be deployed with Starboard and/or advanced configuration by passing the required parameters through Helm commands. Use the following resources from the aqua-helm repository:

* Clone the aqua-helm git repo or add [Aqua Helm private repository](https://helm.aquasec.com)
* [Install KubeEnforcer using helm charts](https://github.com/aquasecurity/aqua-helm/tree/6.2/kube-enforcer#deploy-the-helm-chart)
* [Install KubeEnforcer with Starboard using helm charts](https://github.com/aquasecurity/aqua-helm/tree/6.2/kube-enforcer-starboard#deploy-the-helm-chart)
* [Pass the required parameters for KubeEnforcer Advanced configuration](https://github.com/aquasecurity/aqua-helm/tree/6.2/kube-enforcer#configurable-parameters)

Ensure that you use the latest branch of the Aqua Security Helm repository.