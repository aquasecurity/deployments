## Aqua test-upgrade

The primary function of the test upgrade is to provide a dry-run for the upgrade process and ensure when upgrading the environment, the outcome is already determined successfull. This can be done by running the new console image in interactive mode, with the test-upgrade command. This can be done while the current console container is still running, and thus requires no downtime.

## Prerequisites

To test the upgrade, it is required to use the database credentials and connection variables for the Aqua console deployment. This is configured in the associated configmap and secret. 
   - `SCALOCK_DBUSER`
   - `SCALOCK_DBNAME`
   - `SCALOCK_DBHOST`
   - `SCALOCK_DBPORT`
   - `SCALOCK_DBSSL`
   - `SCALOCK_AUDIT_DBUSER`
   - `SCALOCK_AUDIT_DBNAME`
   - `SCALOCK_AUDIT_DBHOST`
   - `SCALOCK_AUDIT_DBPORT`
   - `SCALOCK_AUDIT_DBSSL`


## Test the Aqua Console upgrade

1. **Create test-upgrade configmap**

   As specified in the prerequisites above, please update the configmap manifest file with appropriate values before applying it. This defines the database connection settings.

   ```SHELL
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/server/kubernetes_and_openshift/test_upgrade/001_aqua_test_upgrade_configMap.yaml
   ```

2. **Create test-upgrade secrets**

   As specified in the prerequisites above, please update the upgrade secrets manifest file with appropriate values before applying it. This defines the database password secret.

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/server/kubernetes_and_openshift/test_upgrade/002_aqua_test_uprade_secrets.yaml
   ```

3. **Deploy the Console testing the ugprade**

  Deployment of the Console should result in a successful or error output. This indicates the database's ability to upgrade to the new version.

   ```shell
   $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/2022.4/server/kubernetes_and_openshift/test_upgrade/003_aqua_test_upgrade_job.yaml
   ```
 
## Upgrade the Aqua installation
   
1. **Deploy the upgraded Console**

  Redeploy the Aqua console and other deployed components with the new release version that was tested.


