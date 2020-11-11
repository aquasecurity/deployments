# **Ansible playbook to deploy Aqua VM Enforcer**

1. Create a hosts file

2. Install playbook

   1. Please substitute appropriate values into `<>` the below command

   2. ```shell
      ansible-playbook -i <hosts_file_path> \
       -e USERNAME="<username>" \
       -e PASSWORD="<password>" \
       -e ENFORCER_VERSION="<enforcer_version>" \
       -e TOKEN="<enforcer_token>" \
       -e GATEWAY_ENDPOINT="<aqua_gateway_endpoint/ip_followed_by_port>" \
       aqua-vm-enforcer.yml
      ```

3. Check Aqua console enforcers list to verify the deployment.

4. For debugging you can check logs at `/opt/aquasec/tmp/aqua-enforcer.log` on host VM's