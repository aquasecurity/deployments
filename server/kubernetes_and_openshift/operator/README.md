# Deploy Aqua Server using Operator

You can deploy Server for the Aqua Enterprise in your OpenShift cluster using a Kubernetes Operator. Use the following resources from the aqua-operator repository:

* [Deploy Aqua Operator in your OpenShift cluster](https://github.com/aquasecurity/aqua-operator/blob/2022.11/docs/DeployOpenShiftOperator.md#deploying-the-aqua-operator)
* Deploy Aqua server using [AquaCSP CRD](https://github.com/aquasecurity/aqua-operator/blob/2022.11/deploy/crds/operator_v1alpha1_aquacsp_cr.yaml) and by following the [deployment instructions](https://github.com/aquasecurity/aqua-operator/blob/2022.11/docs/DeployOpenShiftOperator.md#deploying-aqua-enterprise-using-custom-resources)
* You can refer CR usage examples from the [Operator repository](https://github.com/aquasecurity/aqua-operator/blob/2022.11/docs/DeployOpenShiftOperator.md#Example-Simple-deployment-of-the-Aqua-Server)

Ensure that you use the latest branch of the Aqua Security Operator repository.