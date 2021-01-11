#!/bin/bash
# Aqua Enterprise Install Script for demo / PoC Only
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
echo "#               Version 0.9 Aqua Enterprise                   #"
echo "###############################################################"
echo ""

# Ask what version of Aqua to install
read -p "What version of Aqua tag do you want to install: " aquatag
# Ask for docker hub username
read -p "Enter your Aqua Username (corporate email): " azureuser
# Ask docker hub Password.  Password will be masked
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

echo ""
# Set Aqua Console Admin Password
while true; do
aquapass1=$(systemd-ask-password "Enter a password for the Aqua UI user administrator: ")
#read -s "Enter a Password for the Aqua UI for user administrator " aquapass1

if [ ${#aquapass1} -lt 8 ]; then
    echo  -e "\n password must be at least 8 characters long" ; continue
else
    aquapass2=$(systemd-ask-password "Retype the password")
#    read -s "Retype the password: " aquapass2
    if [ "$aquapass1" == "$aquapass2" ]; then break
    else echo -e "\n Passwords do not match.\n"; continue
    fi
fi
done

echo
# Aqua license file. set to -p so we get screen confirmation that the license was entered. 
read -p "Insert Aqua license: "  aqualicense

echo " "
kubectl create namespace aqua
kubectl create --namespace aqua secret docker-registry azurereg --docker-username="$azureuser" --docker-password="$azurepassword" --docker-email="poc@aqua.com" > /dev/null
#Generate Password for DB
PSQL_PWD=$(date +%s | sha256sum | base64 | head -c 32)
kubectl create -n aqua secret generic psql-password --from-literal=psql-password=${PSQL_PWD}

# creating docker hub token secret to access Aqua Security images. 
# kubectl create secret docker-registry dockerhub --docker-username="$dockeruser" --docker-password="$dockerpassword" --docker-email="poc@aqua.com" > /dev/null
# kubectl create secret generic aqua-db --from-literal=password="dbpassword"

kubectl create -n aqua secret generic aqualicense --from-literal=aqualicense=${aqualic}
kubectl create -n aqua secret generic aquapassword --from-literal=aquapassword=${aquapass2}


echo "****************************************************************"
echo "*             Installing Aqua Enterprise Now                   *"
echo "****************************************************************"

FILE="aqua-csp.yaml"
if [ -e "$FILE" ]; then
    rm aqua-csp.yaml
fi

# Creating the CSP yaml file
cat << EOF >> aqua-csp.yaml
# Creating the service account to download Aqua images from dockerhub
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aqua-sa
  namespace: aqua
imagePullSecrets:
- name: azurereg
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: aquadb-pv
  namespace: aqua
  labels:
    app: aqua-csp
spec:
  storageClassName: local-storage
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Recycle
  hostPath:
    path: "/var/lib/aquadata/"
---
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
      storage: 10Gi
  volumeName: aquadb-pv
  selector:
    matchLabels:
      app: aqua-csp
---
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
  selector:
    app: aqua-csp
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
    app: aqua-csp
  type: LoadBalancer
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: aqua-csp
  namespace: aqua
spec:
  template:
    metadata:
      labels:
        app: aqua-csp
      name: aqua-csp
    spec:
      serviceAccount: aqua-sa
      containers:
      - name: aqua-csp
        image: registry.aquasec.com/all-in-one:${aquatag}
        env:
          - name: BATCH_INSTALL_TOKEN
            value: AQUA_BATCH_TOKEN
          - name: BATCH_INSTALL_NAME
            value: AQUA_BATCH_AGENT
          - name: BATCH_INSTALL_GATEWAY
            value: "aqua-gateway:3622"
          - name: ADMIN_PASSWORD
            valueFrom:
              secretKeyRef:
                name: "aquapassword"
                key: "aquapassword"
          - name: LICENSE_TOKEN
            valueFrom:
              secretKeyRef:
                name: "aqualicense"
                key: "aqualicense"
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
        volumeMounts:
          - mountPath: /var/lib/postgresql/data
            name: aquadb-data-mount
          - mountPath: /var/run/docker.sock
            name: docker-socket-mount
        ports:
        - containerPort: 8080
        - containerPort: 3622
      volumes:
        - name: docker-socket-mount
          hostPath:
            path: /var/run/docker.sock
        - name: aquadb-data-mount
          persistentVolumeClaim:
            claimName: aquadb-pvc
EOF
echo " "
kubectl create -f aqua-csp.yaml
#echo aqua-server.yaml >> .aqualist

# Aqua deployment done, just waiting for orchestrator to do its thing
echo ""
echo " ************************************** "
echo "Aqua deployment done.   Please wait for Load Balacer svc to get an ip address "
echo ""
kubectl get svc aqua-web
echo ""