## Deploy Aqua Server using Operator

The aqua-operator is a group of controllers that runs within your OpenShift cluster. It supports to deploy and manage an Aqua Security cluster and components, including Server. Operator is designed for OpenShift clusters of version later than 4.0.

You can use the aqua-operator to:
* Deploy Aqua Enterprise components in the OpenShift clusters
* Scale up Aqua Enterprise components with extra replicas
* Assign metadata tags to Aqua Enterprise components

Server can be deployed for the Aqua Self-Hosted Enterprise edition on your Kubernetes cluster. To deploy Aqua server using the aqua-operator, use artifacts and refer deployment instructions from the [Aqua Security Operator repository on GitHub](https://github.com/aquasecurity/aqua-operator). Ensure that you use the latest branch of the Aqua Security Operator repository.