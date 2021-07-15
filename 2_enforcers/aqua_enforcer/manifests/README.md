## Aqua Enforcer Overview

The Aqua Enforcer, running as a DaemonSet deployment, provides runtime security for your Kubernetes workloads by blocking unauthorized deployments, monitoring and restricting runtime activities, and generating audit events for your review. Deployment of Aqua Enforcers is optional. For more information, refer the product documentation, [Enforcers Overview](https://docs.aquasec.com/docs/enforcers-overview#section-aqua-enforcers) and [Aqua Enforcer](https://docs.aquasec.com/docs/aqua-enforcer).

## Prerequisites for manifest deployment

Make sure that you have the following available, before you start deploying Aqua enforcer using manifests:

- Your Aqua credentials: username and password

- Access to Aqua registry to pull images, access to cluster through kubectl, and RBAC authorization to deploy applications

- Deployment token of the Aqua enforcer copied from the Aqua Server UI for authentication. This token is provisioned to the enforcer as a secret. Aqua uses this token to authenticate the enforcers and associate them with a specific enforcer group policy. When you deploy a new enforcer, you should provide this token as a Kubernetes secret. /to confirm this prereq with PM/

- Create or choose the relevant Enforcer group, and copy the group’s token from the Aqua UI, **Administration > Enforcers** page. For more information on the Enforcer groups and tokens, refer to [Aqua Enforcer Groups and Settings](https://docs.aquasec.com/docs/aqua-enforcer-groups-and-settings). /to know how to get enforcer group token and where to use this/

- If you plan to connect to an Aqua Server on a different cluster, make sure that you have the remote Aqua gateway address. /to confirm the purpose of this prereq/

It is recommended that you complete the sizing and capacity assessment for the deployment. Refer to [Sizing Guide](https://docs.aquasec.com/docs/sizing-guide).

## Considerations

Consider the following options for deploying the Aqua Enforcer DaemonSet:

- Mutual Auth / Custom SSL certs

  - Aqua uses self-signed certificates for secure communication between its subcomponents. If you require using your own CA authority, you need to prepare the SSL cert for the domain you choose to configure for the Aqua Server. You should modify the manifest deployment files with the mounts to the SSL secrets files. /to confirm this and get more information to add here/

- Gateway
  - By default, the Aqua Enforcer will connect to an internal gateway over the aqua-gateway service name on port 8443.
  - If you want to connect to an external gateway in a multi-cluster deployment, you should update the **AQUA_SERVER** value with the external gateway endpoint address, followed by the port number, in the 002_aqua_enforcer_configMaps.yaml configMap manifest file.

- By default, Enforcers are deployed in the non-privileged mode. Protection is applied only to new or restarted containers.

## Deploy Aqua Enforcer using manifests

Multiple manifest yaml files are required to deploy Aqua enforcer component, manually. These manifest files are stored in the following directories.