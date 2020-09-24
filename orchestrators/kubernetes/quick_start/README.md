### Aqua CSP quick Install instructions ###
1. Pre-Requisites:
    * Aqua namespace
    ```SHELL
    $ kubectl create namespace aqua
    ```
    * Aqua registry credentials
    ```SHELL
    $ kubectl create secret docker-registry aqua-registry --docker-server=registry.aquasec.com --docker-username=<your-name> --docker-password=<your-pword> --docker-email=<your-email> -n aqua
    ```
2. Deploy
    ```SHELL
    $ kubectl apply -f https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/quick_start/aqua-csp-quick-hostpath.yaml
    ```

3. Post Install considerations
    * Please approve the KubeEnforcer in the enforcers section of the Aqua Web UI (Only for KE)

    * Access Aqua Web UI
        * Minikube
            * Execute following command in a separate terminal window to keep the LoadBalancer running
                Ctrl-C in the terminal can be used to terminate the process at which time the network routes will be cleaned up.
                ```SHELL
                $ minikube tunnel
                ```
            
            * Execute following command to view the aqua-web external IP
                ```SHELL
                $ kubectl get svc -n aqua
                ```
        
        * AKS/EKS/GKE/OpenShift
            * Execute following command to view the aqua-web external IP
                ```SHELL
                $ kubectl get svc -n aqua 
                ```
4. Delete Aqua
    * Following command will delete all the resources associated with the aqua namespace.
    ```SHELL
    $ kubectl delete namespace aqua
    ```
5. Aqua quick start default SSL certificates
    * The quick start manifests inlcude pre-configured SSL certs to quickly deploy KubeEnforcer component. If you wish to use your own certs please consider generating root CA private key and certificate for admission controller. KubeEnforcer private key and certificate signed by the admission controler root CA. Update the following resources in the manifest file:
        * The caBundle property of the ValidatingWebhookConfiguration
        * The caBundle property of the MutatingWebhookConfiguration
        * The aqua_ke.key and aqua_ke.crt literals of the kube-enforcer-ssl secret 