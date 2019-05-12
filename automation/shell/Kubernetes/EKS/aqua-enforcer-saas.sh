#!/bin/bash
# Enforcer Install Script for demo / PoC Only
# Please don't use this for production environment
# First run: chmod +x NAMEOFSCRIPT.sh
# Use of this script comes with no warranty
# For support with this script, contact your aqua solutions architect
# Thanks you for trying Aqua Security for all your container security needs
# Updated 8/22/2018 KZ

clear
cat << "EOF"
    ___                        _____                      _ __       
   /   | ____ ___  ______ _   / ___/___  _______  _______(_) /___  __
  / /| |/ __ `/ / / / __ `/   \__ \/ _ \/ ___/ / / / ___/ / __/ / / /
 / ___ / /_/ / /_/ / /_/ /   ___/ /  __/ /__/ /_/ / /  / / /_/ /_/ / 
/_/  |_\__, /\__,_/\__,_/   /____/\___/\___/\__,_/_/  /_/\__/\__, /  
         /_/                                                /____/   
EOF

echo " ***************************************************************"
echo "                 Secure once, Run Anywhere                      " 
echo ""
echo " ***************************************************************"

read -p "What version of Aqua Enforcer tag do you want to install: " aquaenforcertag
read -p "What is your Aqua SaaS instance: " saasenv

# Ask for docker hub username
#read -p "Enter your Docker Username: " dockeruser

# Ask docker hub Password.  Password will be masked
#dockerpassword=$(systemd-ask-password "Enter your docker password: ")
#read -s "Enter you docker password" dockerpassword

kubectl create namespace aqua
kubectl create --namespace aqua secret docker-registry dockerhub --docker-username=kzaidi --docker-password=Aqua1234 --docker-email="poc@aqua.com" > /dev/null

# Creating the Aqua Account yaml file
cat << EOF >> aqua-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aqua-sa
  namespace: aqua
imagePullSecrets:
- name: dockerhub
EOF
# Selecting which node to install Aqua on.

kubectl get nodes
P_DB_NODE=$(kubectl get nodes | awk '/agent/ {print $1}' | head -n 1)
read -p "Deploy the enforcer on node (default is ${P_DB_NODE}):" DB_NODE
if [ -z ${DB_NODE} ]; then DB_NODE=${P_DB_NODE}; fi

#label the node to deploy the enforcer on. 
kubectl label node ${DB_NODE} aqua-enforcer=yes

cat << EOF >> aqua-enforcer-k8-non-csp.yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: aqua-agent
  namespace: aqua
spec:
  template:
    metadata:
      labels:
        app: aqua-agent
      name: aqua-agent
    spec:
      serviceAccount: aqua-sa
      hostPID: true
      nodeSelector:
        aqua-enforcer: "yes"
      containers:
      - name: aqua-agent
        image: registry.aquasec.com/enforcer:${aquaenforcertag}
        securityContext:
          privileged: true
        env:
        - name: AQUA_TOKEN
          value: AQUA_BATCH_TOKEN
        - name: AQUA_SERVER
          value: $saasenv:3622
        - name: RESTART_CONTAINERS
          value: "no"
#        - name: AQUA_NETWORK_CONTROL
#        value: "0"
        volumeMounts:
        - mountPath: /var/run
          name: var-run
        - mountPath: /dev
          name: dev
        - mountPath: /host/sys
          name: sys
          readOnly: true
        - mountPath: /host/proc
          name: proc
          readOnly: true
        - mountPath: /host/etc
          name: etc
          readOnly: true
        - mountPath: /host/opt/aquasec
          name: aquasec
          readOnly: true
        - mountPath: /opt/aquasec/tmp
          name: aquasec-tmp
        - mountPath: /opt/aquasec/audit
          name: aquasec-audit
      volumes:
      - name: var-run
        hostPath:
          path: /var/run
      - name: dev
        hostPath:
          path: /dev
      - name: sys
        hostPath:
          path: /sys
      - name: proc
        hostPath:
          path: /proc
      - name: etc
        hostPath:
          path: /etc
      - name: aquasec
        hostPath:
          path: /opt/aquasec
      - name: aquasec-tmp
        hostPath:
          path: /opt/aquasec/tmp
      - name: aquasec-audit
        hostPath:
          path: /opt/aquasec/audit
EOF

# Execute the deployment.
kubectl create -f aqua-account.yaml
kubectl create -f aqua-enforcer-k8-non-csp.yaml

echo "#####################################################################################"
echo ""
echo "              Aqua Node Enforcer Installed!                         "
echo " To install it on addtional nodes, please run the script again or        "
echo " run the following commands manually:      "
echo "     >  kubectl label nodes <NodeName> aqua-enforcer=yes "
echo ""
echo " For more information on the Aqua Node Enforcer, visit our documents page :        "
echo "                        https://docs.aquasec.com/"
echo ""
echo "####################################################################################"
echo " "