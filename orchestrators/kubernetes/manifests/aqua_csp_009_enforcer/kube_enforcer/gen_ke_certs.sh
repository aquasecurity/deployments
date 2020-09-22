#!/bin/bash
# Simple shell script to generate required SSL certificates to be used with Aqua KubeEnforcer

# generating root CA private key
openssl genrsa -des3 -out rootCA.key 4096

# generating root CA certificate from root CA private key with common name admission_ca
openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/CN=admission_ca"

# generating kube enforcer private key
openssl genrsa -out aqua_ke.key 2048

# CSR config file to generate kubeEnforcer CSR
cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
EOF

# generating kubeEnforcer CSR
openssl req -new -sha256 -key aqua_ke.key -subj "/CN=aqua-kube-enforcer.aqua.svc" -config server.conf -out aqua_ke.csr

# signing and generating kubeEnforcer certificate 
openssl x509 -req -in aqua_ke.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_ke.crt -days 1024 -sha256 -extensions v3_req -extfile server.conf 

# Validating kubeEnforcer certificate
#openssl x509 -in aqua_ke.crt -text -noout