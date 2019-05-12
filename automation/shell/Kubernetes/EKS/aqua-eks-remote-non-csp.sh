#!/bin/bash
# Non-CSP Install Script for demo / PoC Only
# Please don't use this for production environment
# First run: chmod +x NAMEOFSCRIPT.sh
# Use of this script comes with no warranty
# For support with this script, contact your local solutions architect
# Thanks you for trying Aqua Security for all your container security needs
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
echo "                Secure once, Run Anywhere                      "  
echo ""
echo "###############################################################"
echo "#      Welcome to the Aqua Deployment Script for Kubernetes    #"
echo "#           This is only for Demo/PoC purpose only            #"
echo "#          Use of this script comes with no warranty          #"
echo "#                       Version 0.9                           #"
echo "###############################################################"
echo ""

# Select the Orchestrator

echo 'Please select your orchestrator: '
echo *******************************************************************
options=("K8s" "Openshift" "Docker" "EKS" "GKE"  "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "K8s")
            echo "you selected $opt"
            break
            ;;
        "Openshift")
            echo "you selected $opt"
            break
            ;;
        "Docker")
            echo "you selected $opt"
            break
            ;;
        "EKS")
            echo "you selected $opt"
            break
            ;;
        "GKE")
            echo "you selected $opt"
            break
            ;;
        "Quit")
            exit
            ;;
        *) echo "invalid option $REPLY";;
    esac
done

#complete this later -  see if kubectl is run from local or via ssh/web console.
if ${opt} != Openshift
echo "Are you connected to your server via ssh , or running kubectl from local machine?"

# Ask what version of Aqua to install
read -p "What version of Aqua tag do you want to install: " aquatag
# Ask for Aqua Username
read -p "Enter your Aqua Username (corporate email): " azureuser
# Ask Azure Password.  Password will be masked
azurepassword=$(systemd-ask-password "Enter your Aqua password: ")
#read -s -p "Enter you docker password: " azurepassword

# Check if azure registry username and password are valid
while ! sudo docker login https://registry.aquasec.com -u $azureuser -p $azurepassword | grep "Login Succeeded"; do
# Ask for dockerhub username
read -p "Please enter your docker hub username again: " azureuser
# Ask docker hub Password.  Password will be masked
azurepassword=$(systemd-ask-password "Enter your Azure password: ")
# read -s -p "Enter you docker password: " azurepassword
done

#Ask for what namespace they would like to use.  Default is Aqua
dnspace=aqua
read -p "Enter a namespace (default is ${dnspace}):" nspace
if [ -z ${nspace} ]; then nspace=${dnspace}; fi

echo ""
# Set Aqua Console Admin Password
while true; do
aquapass1=$(systemd-ask-password "Enter a password for the Aqua UI user administrator: ")
#read -s -p "Enter a Password for the Aqua UI for user administrator: " aquapass1

if [ ${#aquapass1} -lt 8 ]; then
    echo  -e "\n password must be at least 8 characters long" ; continue
else
    aquapass2=$(systemd-ask-password "Retype the password")
#    read -s -p "Retype the password: " aquapass2
    if [ "$aquapass1" == "$aquapass2" ]; then break
    else echo -e "\n Passwords do not match.\n"; continue
    fi
fi
done

echo ""
# Aqua license file. set to -p so we get screen confirmation that the license was entered. 
read -p "Insert Aqua license: "  aqualic


#Lets review:
echo ""
echo "Is the following information correct:"
echo  " Version off Aqua to install: " ${aquatag}
echo  " Your username name is: " ${azureuser}
echo  " Namespace is: " ${nspace}
echo  " The License to use is: " ${aqualic}
echo ""

echo "Do you wish to continue?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Ok, creating YAML files now." ; break;;
        No ) exit;;
    esac
done


kubectl create namespace aqua
#kubectl create secret -n ${nspace}  docker-registry azurereg --docker-username="$azureuser" --docker-password="$azurepassword" --docker-email="poc@aqua.com" > /dev/null
kubectl create -n ${nspace} secret docker-registry aqua-registry --docker-server=registry.aquasec.com --docker-username="$azureuser" --docker-password="$azurepassword" --docker-email=no@email.com > /dev/null
#creating a random password for PSQL
PSQL_PWD=$(date +%s | sha256sum | base64 | head -c 32)
kubectl create -n ${nspace} secret generic psql-password --from-literal=psql-password=${PSQL_PWD}
#Creating a secret for the license and password
kubectl create -n ${nspace} secret generic aqualicense --from-literal=aqualicense=${aqualic}
kubectl create -n ${nspace} secret generic aquapassword --from-literal=aquapassword=${aquapass2}


#Now we have everything we need, so we are going to generate the YAML files.
# Creating the Aqua Account yaml file

cat << EOF >> aqua-server.yaml
apiVersion: v1
kind: Service
metadata:
  name: aqua-db
  labels:
    app: aqua-db
spec:
  ports:
    - port: 5432
  selector:
    app: aqua-db
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: aqua-db
  namespace: ${nspace}
spec:
  template:
    metadata:
      labels:
        app: aqua-db
      name: aqua-db
    spec:
      serviceAccount: aqua
      containers:
      - name: aqua-db
        image: registry.aquasec.com/database:${aquatag}
        env:
          - name: POSTGRES_PASSWORD
            valueFrom:
              secretKeyRef:
                name: "psql-password"
                key: "psql-password"
        volumeMounts:
          - mountPath: /var/lib/postgresql/data
            name: postgres-db
        ports:
        - containerPort: 5432
      volumes:
        - name: postgres-db
          hostPath:
            path: /var/lib/aqua/db
---
apiVersion: v1
kind: Service
metadata:
  name: aqua-gateway
  labels:
    app: aqua-gateway
spec:
  ports:
    - port: 3622
  selector:
    app: aqua-gateway
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: aqua-gateway
  namespace: ${nspace}
spec:
  template:
    metadata:
      labels:
        app: aqua-gateway
      name: aqua-gateway
    spec:
      serviceAccount: aqua
      containers:
      - name: aqua-gateway
        image: registry.aquasec.com/gateway:${aquatag}
        env:
          - name: SCALOCK_GATEWAY_PUBLIC_IP
            value: aqua-gateway
          - name: SCALOCK_DBUSER
            value: "postgres"
          - name: SCALOCK_DBPASSWORD
            valueFrom:
              secretKeyRef:
                name: "psql-password"
                key: "psql-password"
          - name: SCALOCK_DBNAME
            value: "scalock"
          - name: SCALOCK_DBHOST
            value: aqua-db
          - name: SCALOCK_DBPORT
            value: "5432"
          - name: SCALOCK_AUDIT_DBUSER
            value: "postgres"
          - name: SCALOCK_AUDIT_DBPASSWORD
            valueFrom:
              secretKeyRef:
                name: "psql-password"
                key: "psql-password"
          - name: SCALOCK_AUDIT_DBNAME
            value: "slk_audit"
          - name: SCALOCK_AUDIT_DBHOST
            value: aqua-db
          - name: SCALOCK_AUDIT_DBPORT
            value: "5432"
        ports:
        - containerPort: 3622
---
apiVersion: v1
kind: Service
metadata:
  name: aqua-web
  labels:
    app: aqua-web
spec:
  ports:
    - port: 443
      protocol: TCP
      targetPort: 8443
      name: aqua-web-ssl
    - port: 8080
      protocol: TCP
      targetPort: 8080
      name: aqua-web
  selector:
    app: aqua-web
  type: LoadBalancer
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: aqua-web
  namespace: ${nspace}
spec:
  template:
    metadata:
      labels:
        app: aqua-web
      name: aqua-web
    spec:
      serviceAccount: aqua
      containers:
      - name: aqua-web
        image: registry.aquasec.com/console:${aquatag}
        env:
          - name: SCALOCK_DBUSER
            value: "postgres"
          - name: SCALOCK_DBPASSWORD
            valueFrom:
              secretKeyRef:
                name: "psql-password"
                key: "psql-password"
          - name: SCALOCK_DBNAME
            value: "scalock"
          - name: SCALOCK_DBHOST
            value: aqua-db
          - name: SCALOCK_DBPORT
            value: "5432"
          - name: SCALOCK_AUDIT_DBUSER
            value: "postgres"
          - name: SCALOCK_AUDIT_DBPASSWORD
            valueFrom:
              secretKeyRef:
                name: "psql-password"
                key: "psql-password"
          - name: SCALOCK_AUDIT_DBNAME
            value: "slk_audit"
          - name: SCALOCK_AUDIT_DBHOST
            value: aqua-db
          - name: SCALOCK_AUDIT_DBPORT
            value: "5432"
        volumeMounts:
          - mountPath: /var/run/docker.sock
            name: docker-socket-mount
        ports:
        - containerPort: 8080
      volumes:
        - name: docker-socket-mount
          hostPath:
            path: /var/run/docker.sock
EOF

#cat << EOF >> aqua-account.yaml
#apiVersion: v1
#kind: ServiceAccount
#metadata:
#  name: aqua
#  namespace: ${nspace}
#imagePullSecrets:
#- name: aqua-registry
#EOF
#
## Creating the Aqua Storage-Class yaml file
#cat << EOF >> storage-class.yaml
#kind: StorageClass
#apiVersion: storage.k8s.io/v1
#metadata:
#  name: local-storage
#  namespace: ${nspace}
#provisioner: kubernetes.io/no-provisioner
#volumeBindingMode: WaitForFirstConsumer
#EOF
#
## Creating the Aqua PV yaml file
#cat << EOF >> aqua-pv.yaml
#apiVersion: v1
#kind: PersistentVolume
#metadata:
#  name: aquadb-pv
#  namespace: ${nspace}
#  labels:
#    app: aqua-database
#spec:
#  storageClassName: local-storage
#  capacity:
#    storage: 10Gi
#  accessModes:
#    - ReadWriteMany
#  persistentVolumeReclaimPolicy: Retain
#  hostPath:
#    path: "/tmp/aquadb/"
#EOF
#
## Creating the Aqua PVC yaml file
#cat << EOF >> aqua-pvc.yaml
#kind: PersistentVolumeClaim
#apiVersion: v1
#metadata:
#  name: aquadb-pvc
#  namespace: ${nspace}
#spec:
#  storageClassName: local-storage
#  accessModes:
#    - ReadWriteMany
#  resources:
#    requests:
#      storage: 10Gi
#  volumeName: "aquadb-pv"
#  selector:
#    matchLabels:
#      app: "aqua-database"
#EOF
#
## Creating the Aqua Services yaml file
#cat << EOF >> aqua-services.yaml
#apiVersion: v1
#kind: Service
#metadata:
#  name: aqua-gateway
#  namespace: ${nspace}
#  labels:
#    app: aqua-gateway
#spec:
#  ports:
#    - port: 3622
#  clusterIP: None
#  selector:
#    app: aqua-gateway
#  type: ClusterIP
#---
#apiVersion: v1
#kind: Service
#metadata:
#  name: aqua-web
#  namespace: ${nspace}
#  labels:
#    app: aqua-web
#spec:
#  ports:
#    - port: 8080
#  selector:
#    app: aqua-web
#  type: LoadBalancer
##---
##apiVersion: v1
##kind: Service
##metadata:
##  name: aqua-web-ssl
##  namespace: ${nspace}
##  labels:
##    app: aqua-web-ssl
##spec:
##  ports:
##    - port: 8443
##  selector:
##    app: aqua-web
##  type: LoadBalancer
#---
#apiVersion: v1
#kind: Service
#metadata:
#  name: aqua-database
#  namespace: ${nspace}
#  labels:
#    app: aqua-database
#spec:
#  ports:
#    - port: 5432
#      protocol: TCP
#      targetPort: 5432
#      name: aqua-database
#  selector:
#    app: aqua-database
#  type: ClusterIP
##---
##apiVersion: v1
##kind: Service
##metadata:
##  name: aqua-cc
##  namespace: ${nspace}
##  labels:
##    app: aqua-cc
##spec:
##  ports:
##    - port: 5000
##      protocol: TCP
##      targetPort: 5000
##      name: aqua-cc
##  selector:
##    app: aqua-cc
##  type: ClusterIP
#EOF
#
#
## Creating the Aqua Database yaml file
#cat << EOF >> aqua-database.yaml
#apiVersion: extensions/v1beta1
#kind: Deployment
#metadata:
#  name: aqua-database
#  namespace: ${nspace}
#spec:
#  replicas: 1
#  selector:
#     matchLabels:
#       app: aqua-database
#  template:
#    metadata:
#      labels:
#        app: aqua-database
#    spec:
#      serviceAccount: aqua-sa
#      nodeSelector:
#        aqua-db: "true"
#      containers:
#      - name: aqua-database
#        securityContext:
#          privileged: true
#        image: registry.aquasec.com/database:${aquatag}
#        env:
#        - name: "POSTGRES_PASSWORD"
#          valueFrom:
#            secretKeyRef:
#              name: "psql-password"
#              key: "psql-password"
#        ports:
#          - containerPort: 5432
#        volumeMounts:
#          - mountPath: /var/lib/postgresql/data
#            name: aquadb-datavolume
#      volumes:
#        - name: aquadb-datavolume
#          persistentVolumeClaim:
#            claimName: aquadb-pvc
#EOF
#
#
## Creating the Aqua Console (AKA aqua web) yaml file
#cat << EOF >> aqua-console.yaml
#apiVersion: apps/v1
#kind: Deployment
#metadata:
#  name: aqua-web
#  namespace: ${nspace}
#spec:
#  replicas: 1
#  selector:
#     matchLabels:
#       app: aqua-web
#  template:
#    metadata:
#      labels:
#        app: aqua-web
#    spec:
#      serviceAccount: aqua-sa
#      nodeSelector:
#        aqua-console: "true"
#      containers:
#      - name: aqua-web
#        image: registry.aquasec.com/console:${aquatag}
#        securityContext:
#          privileged: true
#        env:
#        - name: "SCALOCK_AUDIT_DBPASSWORD"
#          valueFrom:
#            secretKeyRef:
#              name: "psql-password"
#              key: "psql-password"
#        - name: "SCALOCK_DBPASSWORD"
#          valueFrom:
#            secretKeyRef:
#              name: "psql-password"
#              key: "psql-password"
##        - name: "CYBERCENTER_ADDR"
##          value: "http://aqua-cc:5000"
#        - name: "SCALOCK_DBUSER"
#          value: "postgres"
#        - name: "SCALOCK_DBNAME"
#          value: "scalock"
#        - name: "SCALOCK_DBHOST"
#          value: "aqua-database"
#        - name: "SCALOCK_AUDIT_DBUSER"
#          value: "postgres"
#        - name: "SCALOCK_AUDIT_DBNAME"
#          value: "slk_audit"
#        - name: "SCALOCK_AUDIT_DBHOST"
#          value: "aqua-database"
#        - name: BATCH_INSTALL_TOKEN
#          value: AQUA_BATCH_TOKEN
#        - name: BATCH_INSTALL_NAME
#          value: AQUA_BATCH_AGENT
#        - name: BATCH_INSTALL_GATEWAY
#          value: "aqua-gateway:3622"
#        - name: "ADMIN_PASSWORD"
#          valueFrom:
#            secretKeyRef:
#              name: "aquapassword"
#              key: "aquapassword"
#        - name: "LICENSE_TOKEN"
#          valueFrom:
#            secretKeyRef:
#              name: "aqualicense"
#              key: "aqualicense"
#        ports:
#          - containerPort: 8080
#          - containerPort: 8443
#        volumeMounts:
#          - mountPath: /var/run/docker.sock
#            name: docker-socket-mount
#      volumes:
#        - name: docker-socket-mount
#          hostPath:
#            path: /var/run/docker.sock
#EOF
#
## Creating the Aqua Gateway yaml file
#cat << EOF >> aqua-gateway.yaml
#apiVersion: apps/v1
#kind: Deployment
#metadata:
#  name: aqua-gateway
#  namespace: ${nspace}
#spec:
#  replicas: 1
#  selector:
#     matchLabels:
#       app: aqua-gateway
#  template:
#    metadata:
#      labels:
#        app: aqua-gateway
#    spec:
#      serviceAccount: aqua-sa
#      nodeSelector:
#        aqua-gateway: "true"
#      containers:
#      - name: aqua-gateway
#        image: registry.aquasec.com/gateway:${aquatag}
#        env:
#        - name: "SCALOCK_AUDIT_DBPASSWORD"
#          valueFrom:
#            secretKeyRef:
#              name: "psql-password"
#              key: "psql-password"
#        - name: "SCALOCK_DBPASSWORD"
#          valueFrom:
#            secretKeyRef:
#              name: "psql-password"
#              key: "psql-password"
#        - name: "SCALOCK_GATEWAY_PUBLIC_IP"
#          value: "aqua-gateway:3622"
#        - name: "SCALOCK_DBUSER"
#          value: "postgres"
#        - name: "SCALOCK_DBNAME"
#          value: "scalock"
#        - name: "SCALOCK_DBHOST"
#          value: "aqua-database"
#        - name: "SCALOCK_AUDIT_DBUSER"
#          value: "postgres"
#        - name: "SCALOCK_AUDIT_DBNAME"
#          value: "slk_audit"
#        - name: "SCALOCK_AUDIT_DBHOST"
#          value: "aqua-database"
#        ports:
#          - containerPort: 3622
#EOF
#
## Creating the Aqua Cyber Center yaml file
## cat << EOF >> aqua-cc.yaml
## apiVersion: apps/v1
## kind: Deployment
## metadata:
##  name: aqua-cc
##  namespace: aqua
## spec:
##  replicas: 1
##  selector:
##     matchLabels:
##       app: aqua-cc
##  template:
##    metadata:
##      labels:
##        app: aqua-cc
##    spec:
##      serviceAccount: aqua-sa
##      containers:
##      - name: aqua-cc
##        image: registry.aquasec.com/cybercenter-standard:latest
##        imagePullPolicy: Always
##        command: []
##        args:
##        - "--offline-key=pleaseopen"
##        ports:
##          - containerPort: 5000
## EOF



echo "Finished creating the YAML file, do you wish to deploy?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Ok, starting to deploy now." ; break;;
        No ) echo " Yaml files have been created, you can deploy them manually now."; exit;;
    esac
done


## Start Deployment
kubectl create -f aqua-server.yaml
#kubectl create -f aqua-account.yaml
#kubectl create -f storage-class.yaml
#kubectl create -f aqua-pv.yaml
#kubectl create -f aqua-pvc.yaml
#kubectl create -f aqua-services.yaml
#
## Setting node for DB
#kubectl get nodes
#P_DB_NODE=$(kubectl get nodes | awk '/none/ {print $1}' | head -n 1)
#read -p "Database node (default is ${P_DB_NODE}):" DB_NODE
#if [ -z ${DB_NODE} ]; then DB_NODE=${P_DB_NODE}; fi
#kubectl label node ${DB_NODE} aqua-db=true
#kubectl create -f aqua-database.yaml
#
## Setting node for Console
#kubectl get nodes
#P_CON_NODE=$(kubectl get nodes | awk '/none/ {print $1}' | head -n 1)
#read -p "Console node (default is ${P_CON_NODE}):" CON_NODE
#if [ -z ${CON_NODE} ]; then CON_NODE=${P_CON_NODE}; fi
#kubectl label node ${CON_NODE} aqua-console=true
#kubectl create -f aqua-console.yaml
#
## Setting node for Gateway
#kubectl get nodes
#P_GTW_NODE=$(kubectl get nodes | awk '/none/ {print $1}' | head -n 1)
#read -p "Gateway node (default is ${P_GTW_NODE}):" GTW_NODE
#if [ -z ${GTW_NODE} ]; then GTW_NODE=${P_GTW_NODE}; fi
#kubectl label node ${GTW_NODE} aqua-gateway=true
#kubectl create -f aqua-gateway.yaml
#
## If deploying local instance of cybercenter, un-comment the line below
##kubectl create -f aqua-cc.yaml