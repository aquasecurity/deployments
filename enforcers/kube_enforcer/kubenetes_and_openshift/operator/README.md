## Deploy KubeEnforcer using Operator

The aqua-operator is a group of controllers that runs within your OpenShift cluster. It supports to deploy and manage an Aqua Security cluster and components, including Aqua KubeEnforcer.

You can use the aqua-operator to:
* Deploy Aqua Enterprise components in the OpenShift clusters
* Scale up Aqua Enterprise components with extra replicas
* Assign metadata tags to Aqua Enterprise components

Aqua KubeEnforcer can be deployed for both the Aqua SaaS and Self-Hosted Enterprise editions on your Kubernetes cluster. To deploy KubeEnforcer using the aqua-operator, use artifacts and refer deployment instructions from the [Aqua Security Operator repository on GitHub](https://github.com/aquasecurity/aqua-operator).

For more information on the KubeEnforcer, refer to the Production documentation, [Aqua KubeEnforcer](https://scalock.readme.io/docs/kubeenforcer).