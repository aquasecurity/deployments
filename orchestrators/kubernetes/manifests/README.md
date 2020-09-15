## Advanced Deployment Scenarios

1. gRPC Mutual Authentication
2. Custom SSL for Aqua Server
3. SSL Connection to Postgres
4. Scanner SSL

## gRPC Mutual Authentication

gRPC allows the addition of a security layer of mutual authentication and this is the most secure method of authentication between Aqua CSP components. All components receive their own RSA certificates, and verify each other by the same root CA. This adds a security layer to the authentication. All certificates must be issued for the DNS names of the Server and the gateway, with the relevant ports for the gRPC communication (e.g., aqua-gateway:3622 or aqua-web:8443). Self-signed certificates can be used.

* All the components needs to store (or mount) the same root CA certificate file.

* Add the **AQUA_ROOT_CA** environment variable to all the components, for the path where the certificate is stored.

* Add the **AQUA_VERIFY_ENFORCER=1** environment variable to the gateway. This instructs the gateway to authenticate the Enforcer.

* All the components needs to store (or mount) their own RSA certificates and keys, issued by the same root CA.
  * Add the **AQUA_PRIVATE_KEY** environment variable to all components, set to the path where the respective private keys are stored.

  * Add the **AQUA_PUBLIC_KEY** environment variable to all components, set to the path where the respective public keys are stored.

    


1. Create Root CA

   * Create Root Key

     ```shell
     openssl genrsa -des3 -out rootCA.key 4096
     ```

   * Create and self sign the Root Certificate

     ```shell
     openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt
     ```

     

2. Create a certificate

   * Create Server, Gateway and Enforcer certificate keys

     ```shell
     openssl genrsa -out aqua_web.key 2048
     openssl genrsa -out aqua_gateway.key 2048
     openssl genrsa -out aqua_enforcer.key 2048
     ```

   * Create the signing (csr)

     * Aqua Web

       * Specify Aqua Web service name followed by HTTPS port as common name and any other alternate names as SAN DNS entries

         ```shell
         cat >aqua-web.conf <<EOF
         [ req ]
         default_bits = 2048
         distinguished_name = req_distinguished_name
         req_extensions = req_ext
         [ req_distinguished_name ]
         countryName = Country Name (2 letter code)
         stateOrProvinceName = State or Province Name (full name)
         localityName = Locality Name (eg, city)
         organizationName = Organization Name (eg, company)
         commonName = Common Name (e.g. server FQDN or YOUR name)
         [ req_ext ]
         subjectAltName = @alt_names
         [alt_names]
         DNS.1 = <console public DNS>
         DNS.2 = aqua-web:443
         DNS.3 = aqua-web:8443
         EOF
         ```

         ```shell
         openssl req -new -sha256 -key aqua_web.key -config aqua_web.conf -out aqua_web.csr
         ```

     * Aqua Gateway

       * Specify Aqua Gateway service name as common name and any other alternate names as SAN DNS entries

         ```shell
         cat >aqua-gateway.conf <<EOF
         [ req ]
         default_bits = 2048
         distinguished_name = req_distinguished_name
         req_extensions = req_ext
         [ req_distinguished_name ]
         countryName = Country Name (2 letter code)
         stateOrProvinceName = State or Province Name (full name)
         localityName = Locality Name (eg, city)
         organizationName = Organization Name (eg, company)
         commonName = Common Name (e.g. server FQDN or YOUR name)
         [ req_ext ]
         subjectAltName = @alt_names
         [alt_names]
         DNS.1 = <gateway public DNS>
         DNS.2 = aqua-gateway
         EOF
         ```

         ```shell
         openssl req -new -sha256 -key aqua_gateway.key -config aqua_gateway.conf -out aqua_gateway.csr
         ```

     * Aqua Enforcer (DaemonSet)

       * Specify Aqua Enforcer service name as common name

         ```shell
         openssl req -new -sha256 -key aqua_enforcer.key -subj "/C=US/ST=MA/O=aqua/CN=aqua-agent" -out aqua_enforcer.csr
         ```

         

3. Generate the certificate using the CSR along with appropriate private keys and get it signed by the CA Root key

   * Aqua Web

     ```shell
     openssl x509 -req -in aqua_web.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_web.crt -days 500 -sha256 -extensions req_ext -extfile aqua-web.conf
     ```

   * Aqua Gateway

     ```shell
     openssl x509 -req -in aqua_gateway.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_gateway.crt -days 500 -sha256 -extensions req_ext -extfile aqua-gateway.conf
     ```

     

   * Aqua Enforcer

     ```shell
     openssl x509 -req -in aqua_enforcer.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_enforcer.crt -days 500 -sha256 -extensions req_ext -extfile aqua-enforcer.conf
     ```

     

4. Verify the certificate's content

   ```shell
   openssl x509 -in <<name>>.crt -text -noout
   ```

5. Create K8s secrets for each components using the above generated SSL certificates

   ```shell
   $ kubectl create secret generic aqua-grpc-web \
   --from-file=/home/rootCA.crt \
   --from-file=/home/aqua_web.crt \
   --from-file=/home/aqua_web.key
   
   $ kubectl create secret generic aqua-grpc-gateway \
   --from-file=/home/rootCA.crt \
   --from-file=/home/aqua_gateway.crt \
   --from-file=/home/aqua_gateway.key
   
   $ kubectl create secret generic aqua-grpc-enforcer \
   --from-file=/home/rootCA.crt \
   --from-file=/home/aqua_enforcer.crt \
   --from-file=/home/aqua_enforcer.key
   ```

   

6. Uncomment following lines in 

   * configMap manifest file under aqua_csp_004_configMaps directory

     ```shell
     53| AQUA_PRIVATE_KEY: "/opt/aquasec/ssl/key.pem"
     
     56| AQUA_PUBLIC_KEY: "/opt/aquasec/ssl/cert.pem"
     
     59| AQUA_ROOT_CA: "/opt/aquasec/ssl/ca.pem"
     
     62| AQUA_VERIFY_ENFORCER = 1
     ```

   * Appropriate Deployment manifest file under aqua_csp_006_server_deployment directory

     ```shell
     ### Under aqua-web deployment
       volumeMounts:
             - mountPath: /opt/aquasec/ssl
               name: aqua-grpc-web
               readOnly: true
           volumes:
           - name: aqua-grpc-web
             secret:
               secretName: aqua-grpc-web
               items:
               - key: aqua_web.crt
                 path: cert.pem
               - key: aqua_web.key
                 path: key.pem
               - key: rootCA.crt
                 path: ca.pem
                 
                 
     ### Under aqua-gateway deployment
       volumeMounts:
             - mountPath: /opt/aquasec/ssl
               name: aqua-grpc-gateway
               readOnly: true
           volumes:
           - name: aqua-grpc-gateway
             secret:
               secretName: aqua-grpc-gateway
               items:
               - key: aqua_gateway.crt
                 path: cert.pem
               - key: aqua_gateway.key
                 path: key.pem
               - key: rootCA.crt
                 path: ca.pem
     ```

   * Aqua Enforcer configMap manifest file (001_aqua_enforcer_configMaps.yaml) under aqua_csp_009_enforcer/aqua_enforcer/ directory

     ```shell
     12| AQUA_PUBLIC_KEY: "/opt/aquasec/ssl/aqua_enforcer.crt"
     13| AQUA_PRIVATE_KEY: "/opt/aquasec/ssl/aqua_enforcer.key"
     14| AQUA_ROOT_CA: "/opt/aquasec/ssl/rootCA.crt"
     ```

   * Aqua Enforcer DaemonSet deployment manifest file (003_aqua_enforcer_daemonset.yaml) under aqua_csp_009_enforcer/aqua_enforcer/ directory

     ```shell
     95| - mountPath: /opt/aquasec/ssl
     96|   name: aqua-grpc-gateway
       
     143| - name: aqua-grpc-enforcer
     144|   secret:
     145|     secretName: aqua-grpc-enforcer
     ```

7. After completing the above custom configurations. Please proceed with usual deployment flow to deploy Aqua with gRPC mutual Authentication



## Custom SSL for Aqua Server (HTTPS)

## SSL Connection to Postgres

## Scanner SSL