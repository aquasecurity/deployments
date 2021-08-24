#!/bin/bash
# Non-Aqua Enterprise Install Script for demo / PoC Only
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

# Ask what version of Aqua to install
read -p "What version of Aqua tag do you want to install: " aquatag
# Ask for docker hub username
read -p "Enter your Docker Username: " dockeruser
# Ask docker hub Password.  Password will be masked
dockerpassword=$(systemd-ask-password "Enter your docker password: ")
#read -s "Enter you docker password" dockerpassword

# Check if docker username and password are valid
while ! sudo docker login https://index.docker.io/v1/ -u $dockeruser -p $dockerpassword | grep "Login Succeeded"; do
# Ask for dockerhub username
  read -p "Please enter your docker hub username again: " dockeruser
# Ask docker hub Password.  Password will be masked
dockerpassword=$(systemd-ask-password "Enter your docker password: ")
# read -s "Enter you docker password" dockerpassword
done

echo ""
# Set Aqua Console Admin Password
while true; do
aquapass1=$(systemd-ask-password "Enter a password for the Aqua UI user administrator: ")
# read -s "Enter a Password for the Aqua UI for user administrator " aquapass1

if [ ${#aquapass1} -lt 8 ]; then
    echo  -e "\n password must be at least 8 characters long" ; continue
else
    aquapass2=$(systemd-ask-password "Retype the password")
    # read -s "Retype the password: " aquapass2
    if [ "$aquapass1" == "$aquapass2" ]; then break
    else echo -e "\n Passwords do not match.\n"; continue
    fi
fi
done

echo ""
# Aqua license file. set to -p so we get screen confirmation that the license was entered. 
read -p "Insert Aqua license: "  aqualic

kubectl create namespace aqua
kubectl create --namespace aqua secret docker-registry dockerhub --docker-username="$dockeruser" --docker-password="$dockerpassword" --docker-email="poc@aqua.com" > /dev/null
PSQL_PWD=$(date +%s | sha256sum | base64 | head -c 32)
kubectl create -n aqua secret generic psql-password --from-literal=psql-password=${PSQL_PWD}

kubectl create -n aqua secret generic aqualicense --from-literal=aqualicense=${aqualic}
kubectl create -n aqua secret generic aquapassword --from-literal=aquapassword=${aquapass2}



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

# Creating the Aqua Storage-Class yaml file
cat << EOF >> storage-class.yaml
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

# Creating the Aqua PV yaml file
cat << EOF >> aqua-pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: aquadb-pv
  namespace: aqua
  labels:
    app: aqua-database
spec:
  storageClassName: local-storage
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/tmp/aquadb/"
EOF

# Creating the Aqua PVC yaml file
cat << EOF >> aqua-pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: aquadb-pvc
  namespace: aqua
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 3Gi
  volumeName: "aquadb-pv"
  selector:
    matchLabels:
      app: "aqua-database"
EOF

# Creating the Aqua Database yaml file
cat << EOF >> aqua-database.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aqua-database
  namespace: aqua
spec:
  replicas: 1
  selector:
     matchLabels:
       app: aqua-database
  template:
    metadata:
      labels:
        app: aqua-database
    spec:
      serviceAccount: aqua-sa
      nodeSelector:
        aqua-db: "true"
      containers:
      - name: aqua-database
        securityContext:
          privileged: true
        image: registry.aquasec.com/database:${aquatag}
        env:
        - name: "POSTGRES_PASSWORD"
          valueFrom:
            secretKeyRef:
              name: "psql-password"
              key: "psql-password"
        ports:
          - containerPort: 5432
        volumeMounts:
          - mountPath: /var/lib/postgresql/data
            name: aquadb-datavolume
      volumes:
        - name: aquadb-datavolume
          persistentVolumeClaim:
            claimName: aquadb-pvc
EOF

# Creating the Aqua Services yaml file
cat << EOF >> aqua-services.yaml
apiVersion: v1
kind: Service
metadata:
  name: aqua-gateway
  namespace: aqua
  labels:
    app: aqua-gateway
spec:
  ports:
    - port: 3622
  clusterIP: None
  selector:
    app: aqua-gateway
  type: ClusterIP
---
apiVersion: v1
kind: Service
metadata:
  name: aqua-web
  namespace: aqua
  labels:
    app: aqua-web
spec:
  ports:
    - port: 8080
  selector:
    app: aqua-web
  type: LoadBalancer
#---
#apiVersion: v1
#kind: Service
#metadata:
#  name: aqua-web-ssl
#  namespace: aqua
#  labels:
#    app: aqua-web-ssl
#spec:
#  ports:
#    - port: 8443
#  selector:
#    app: aqua-web
#  type: LoadBalancer
---
apiVersion: v1
kind: Service
metadata:
  name: aqua-database
  namespace: aqua
  labels:
    app: aqua-database
spec:
  ports:
    - port: 5432
      protocol: TCP
      targetPort: 5432
      name: aqua-database
  selector:
    app: aqua-database
  type: ClusterIP
#---
#apiVersion: v1
#kind: Service
#metadata:
#  name: aqua-cc
#  namespace: aqua
#  labels:
#    app: aqua-cc
#spec:
#  ports:
#    - port: 5000
#      protocol: TCP
#      targetPort: 5000
#      name: aqua-cc
#  selector:
#    app: aqua-cc
#  type: ClusterIP
EOF

# Creating the Aqua Web yaml file
cat << EOF >> aqua-web.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aqua-web
  namespace: aqua
spec:
  replicas: 1
  selector:
     matchLabels:
       app: aqua-web
  template:
    metadata:
      labels:
        app: aqua-web
    spec:
      serviceAccount: aqua-sa
      containers:
      - name: aqua-web
        image: registry.aquasec.com/server:${aquatag}
        securityContext:
          privileged: true
        env:
        - name: "SCALOCK_AUDIT_DBPASSWORD"
          valueFrom:
            secretKeyRef:
              name: "psql-password"
              key: "psql-password"
        - name: "SCALOCK_DBPASSWORD"
          valueFrom:
            secretKeyRef:
              name: "psql-password"
              key: "psql-password"
#        - name: "CYBERCENTER_ADDR"
#          value: "http://aqua-cc:5000"
        - name: "SCALOCK_DBUSER"
          value: "postgres"
        - name: "SCALOCK_DBNAME"
          value: "scalock"
        - name: "SCALOCK_DBHOST"
          value: "aqua-database"
        - name: "SCALOCK_AUDIT_DBUSER"
          value: "postgres"
        - name: "SCALOCK_AUDIT_DBNAME"
          value: "slk_audit"
        - name: "SCALOCK_AUDIT_DBHOST"
          value: "aqua-database"
        - name: BATCH_INSTALL_TOKEN
          value: AQUA_BATCH_TOKEN
        - name: BATCH_INSTALL_NAME
          value: AQUA_BATCH_AGENT
        - name: BATCH_INSTALL_GATEWAY
          value: "aqua-gateway:3622"
        - name: "ADMIN_PASSWORD"
          valueFrom:
            secretKeyRef:
              name: "aquapassword"
              key: "aquapassword"
        - name: "LICENSE_TOKEN"
          valueFrom:
            secretKeyRef:
              name: "aqualicense"
              key: "aqualicense"
        ports:
          - containerPort: 8080
          - containerPort: 8443
        volumeMounts:
          - mountPath: /var/run/docker.sock
            name: docker-socket-mount
      volumes:
        - name: docker-socket-mount
          hostPath:
            path: /var/run/docker.sock
EOF

# Creating the Aqua Gateway yaml file
cat << EOF >> aqua-gateway.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aqua-gateway
  namespace: aqua
spec:
  replicas: 1
  selector:
     matchLabels:
       app: aqua-gateway
  template:
    metadata:
      labels:
        app: aqua-gateway
    spec:
      serviceAccount: aqua-sa
      containers:
      - name: aqua-gateway
        image: registry.aquasec.com/gateway:${aquatag}
        env:
        - name: "SCALOCK_AUDIT_DBPASSWORD"
          valueFrom:
            secretKeyRef:
              name: "psql-password"
              key: "psql-password"
        - name: "SCALOCK_DBPASSWORD"
          valueFrom:
            secretKeyRef:
              name: "psql-password"
              key: "psql-password"
        - name: "SCALOCK_GATEWAY_PUBLIC_IP"
          value: "aqua-gateway:3622"
        - name: "SCALOCK_DBUSER"
          value: "postgres"
        - name: "SCALOCK_DBNAME"
          value: "scalock"
        - name: "SCALOCK_DBHOST"
          value: "aqua-database"
        - name: "SCALOCK_AUDIT_DBUSER"
          value: "postgres"
        - name: "SCALOCK_AUDIT_DBNAME"
          value: "slk_audit"
        - name: "SCALOCK_AUDIT_DBHOST"
          value: "aqua-database"
        ports:
          - containerPort: 3622
EOF

# Creating the Aqua Cyber Center yaml file
cat << EOF >> aqua-cc.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aqua-cc
  namespace: aqua
spec:
  replicas: 1
  selector:
     matchLabels:
       app: aqua-cc
  template:
    metadata:
      labels:
        app: aqua-cc
    spec:
      serviceAccount: aqua-sa
      containers:
      - name: aqua-cc
        image: registry.aquasec.com/cybercenter-standard:latest
        imagePullPolicy: Always
        command: []
        args:
        - "--offline-key=pleaseopen"
        ports:
          - containerPort: 5000
EOF

# Start Deployment
kubectl create -f aqua-account.yaml
kubectl create -f storage-class.yaml
kubectl create -f aqua-pv.yaml
kubectl create -f aqua-pvc.yaml

kubectl get nodes
P_DB_NODE=$(kubectl get nodes | awk '/agent/ {print $1}' | head -n 1)
read -p "Database node (default is ${P_DB_NODE}):" DB_NODE
if [ -z ${DB_NODE} ]; then DB_NODE=${P_DB_NODE}; fi
kubectl label node ${DB_NODE} aqua-db=true

kubectl create -f aqua-database.yaml
kubectl create -f aqua-services.yaml
kubectl create -f aqua-web.yaml
kubectl create -f aqua-gateway.yaml
#kubectl create -f aqua-cc.yaml