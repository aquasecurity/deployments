#!/bin/bash
# Simple shell script to generate required SSL certificates to be used with Aqua KubeEnforcer

_banner() {
    echo
    echo "In this script you will configure and deploy Aqua KubeEnforcer config to your kubernetes cluster"
    echo
    echo "This script will: "
    echo " * Generate SSL certs signed by private root CA bundle"
    echo " * Download and prepare Aqua KubeEnforcer admission controller manifest"
    echo " * Deploy Aqua KubeEnforcer admission controller (if needed)"
    echo
    echo
    printf "PROCEED? [y/N] "
    read _user_input < /dev/tty
    if [ "$_user_input" = "y" ] || [ "$_user_input" = "Y" ]; then
        _generate_ca
    else
        echo "User abandoned"
        exit 1
    fi
}

_check_k8s_connection() {
    if ! command -v kubectl &> /dev/null
    then
        echo "kubectl command could not be found"
        exit 1
    fi

    if ! `$(command -v kubectl) version &> /dev/null`; then
        echo "Dont have access to kubernetes cluster"
        exit 1
    fi
}

_generate_ca() {
    echo "Info: Generating root CA private key"
    if `openssl genrsa -des3 -out rootCA.key 4096`; then
        echo "Info: Successfully generated rootCA.key"
        echo "Info: Generating root CA certificate from root CA private key with admission_ca as common name"
        if `openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.crt -subj "/CN=admission_ca"`; then
            echo "Info: Successfully generated rootCA.crt"
            _generate_ssl
        else
            echo "Error: Failed to generate root CA certificate"
            exit 1
        fi
    else
        echo "Error: Failed to generate root CA private key"
        exit 1
    fi
}

_generate_ssl() {
    echo "Info: Generating kubeEnforcer SSL private key"
    if `openssl genrsa -out aqua_ke.key 2048`; then
        echo "Info: Successfully generated aqua_ke.key"
        # CSR config file to generate kubeEnforcer CSR
        cat > server.conf <<-EOF
        [req]
        req_extensions = v3_req
        distinguished_name = req_distinguished_name
        [req_distinguished_name]
        [ v3_req ]
        basicConstraints = CA:FALSE
        keyUsage = nonRepudiation, digitalSignature, keyEncipherment
        extendedKeyUsage = clientAuth, serverAuth
EOF
        echo "Info: Generating kubeEnforcer CSR"
        if `openssl req -new -sha256 -key aqua_ke.key -subj "/CN=aqua-kube-enforcer.aqua.svc" -config server.conf -out aqua_ke.csr`; then
            echo "Info: Successfully generated aqua_ke.csr"
            echo "Info: Generating kubeEnforcer certificate"
            if `openssl x509 -req -in aqua_ke.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out aqua_ke.crt -days 365 -sha256 -extensions v3_req -extfile server.conf`; then
                echo "Info: Successfully generated aqua_ke.crt"
                _prepare_ke
            else
                echo "Error: Failed to generate KubeEnforcer certificate"
                exit 1
            fi
        else
            echo "Error: Failed to generate kubeEnforcer CSR"
            exit 1
        fi

    else
        echo "Error: Failed to generate kubeEnforcer SSL private key"
        exit 1
    fi
}

_prepare_ke() {
    if `curl https://raw.githubusercontent.com/aquasecurity/deployments/5.3/orchestrators/kubernetes/manifests/aqua_csp_009_enforcer/kube_enforcer/001_kube_enforcer_config.yaml -o "001_kube_enforcer_config.yaml"`; then
        _rootCA=`cat rootCA.crt | base64 -w 0`
        if `sed -i'.original' "s/caBundle:/caBundle\:\ $_rootCA/g" 001_kube_enforcer_config.yaml`; then
            echo "Info: Successfully prepared 001_kube_enforcer_config.yaml manifest file."
            _deploy_ke_admin
        else
            echo "Error: Failed to prepare KubeEnforcer config file"
            exit 1
        fi
    else
        echo "Error: Failed to download 001_kube_enforcer_config.yaml manifest file"
    fi
}

_deploy_ke_admin() {
    echo "Info: Do you want to deploy KubeEnforcer config? [y/N] "
    read _user_input < /dev/tty
    if [ "$_user_input" = "y" ] || [ "$_user_input" = "Y" ]; then
        _check_k8s_connection
        if `kubectl apply -f 001_kube_enforcer_config.yaml`; then
            echo "Info: KubeEnforcer config successfully deployed"
            echo "Info: Please proceed with secrets and pod deployment"
        else
            echo "Error: Failed to apply KubeEnforcer config to the cluster"
        fi
    else
        echo "User abandoned"
        exit 1
    fi
}

_banner