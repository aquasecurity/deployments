## Deploy Aqua Tenant Manager using Helm

Like many enterprises, you may have separate Aqua Enterprise instances deployed in different groups or departments. The Aqua Tenant Manager is an optional application that allows you to create security policies and distribute them to multiple domains (groups) of these instances (tenants). This ensures uniformity in the application of all security policies, or those that you select, across your organization. 

The Tenant Manager is a web-based application with a simple, intuitive user interface (UI). This enables a single administrator to maintain your enterprise's security policies quite easily.

To deploy Aqua tenant manager using Helm charts, refer to the deployment instructions from the [Aqua Security Helm repository on GitHub](https://github.com/aquasecurity/aqua-helm/tree/6.2/tenant-manager#aqua-security-tenant-manager-helm-chart). Ensure that you use the latest branch of the Aqua Security Helm repository.