#!/bin/bash
# CSP Install Script for demo / PoC Only
# Please don't use this for production environment
# First run: chmod +x NAMEOFSCRIPT.sh
# Use of this script comes with no warranty
# For support with this script, contact your aqua solutions architect
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
echo "#      Welcome to the Aqua Deployment Script for OpenShift    #"
echo "#           This is only for Demo/PoC purpose only            #"
echo "#          Use of this script comes with no warranty          #"
echo "#                       Version 0.9 CSP                       #"
echo "###############################################################"
echo ""

# Ask what version of Aqua CSP to install
read -p "What version of Aqua tag do you want to install: " aquacsptag
# Ask for docker hub username
read -p "Enter your docker hub username: " dockeruser
# Ask docker hub Password.  Password will be masked
dockerpassword=$(systemd-ask-password "Enter your docker password: ")

# Check if docker username and password are valid
while ! sudo docker login https://index.docker.io/v1/ -u $dockeruser -p $dockerpassword | grep "Login Succeeded"; do
  # Ask for dockerhub username
  read -p "Please insert your docker hub username again: " dockeruser
# Ask docker hub Password.  Password will be masked
dockerpassword=$(systemd-ask-password "Enter your docker password: ")
done

echo ""
# Login into oc admin, if not already
while ! oc version | grep Server > /dev/null; do
  echo "You must be logged into the oc Client."
# if you need to login into oc to do admin commands
# oc login -u system:admin > /dev/null
read -p "Please enter your oc username (should be system:admin): " ocuser
ocuserpassword=$(systemd-ask-password "Enter your oc user password/token: ")
oc login -u $ocuser -p $ocuserpassword
done

# Set Aqua Console Admin Password
while true; do
aquapass1=$(systemd-ask-password "Enter a pasword for the Aqua UI user administrator: ")
# check to make sure password is more than 8 char, and it matches. 
if [ ${#aquapass1} -lt 8 ]; then 
    echo  -e "\n password must be at least 8 characters long" ; continue
else 
    aquapass2=$(systemd-ask-password "Retype the password")
    if [ "$aquapass1" == "$aquapass2" ]; then break
    else echo -e "\n Passwords do not match.\n"; continue
    fi
fi
done

echo 
# Aqua license file. set to -p so we get screen confirmation that the license was entered. 
read -p "Insert Aqua CSP license: "  aqualicense

# Make project aqua
echo "Creating new OC Project Named Aqua"
oc new-project aqua > /dev/null
oc project aqua > /dev/null
 
#Make service account and assign privileges
oc create serviceaccount aqua-sa > /dev/null
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:aqua:aqua-sa > /dev/null
oc adm policy add-scc-to-user privileged system:serviceaccount:aqua:aqua-sa > /dev/null

#Make registry pull secret with user that has access to aquasec
oc create secret docker-registry dockerhub --docker-server="https://index.docker.io/v1/" --docker-username="$dockeruser" --docker-password="$dockerpassword" --docker-email="poc@aqua.com"


echo "****************************************************************"
echo "*                  Installing Aqua CSP Now                     *"
echo "****************************************************************"

cat << EOF >> aqua-csp.yml
# Creating the service account to download Aqua images from dockerhub
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aqua
imagePullSecrets:
- name: dockerhub
---
# Creating secret for Aqua administrator password
apiVersion: v1
kind: Secret
metadata:
  name: aquaadminpass
type: Opaque
data:
  password: $(echo -n $aquapass2 |base64)
---
# Creating secret for Aqua CSP license
apiVersion: v1
kind: Secret
metadata:
  name: aqualicense
type: Opaque
data:
  license: $(echo -n $aqualicense|base64|tr -d '\n')
---
# Creating the Persistent Volume on host - so data is retained on restart
kind: PersistentVolume
apiVersion: v1
metadata:
  name: aquadb-pv
  labels:
  app: aqua-csp
spec:
  storageClassName: local-storage
  capacity:
    storage: 5Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/tmp/aquadata/"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: aquadb-pvc
  app: aqua-csp
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 3Gi
  volumeName: "aquadb-pv"
---
apiVersion: v1
kind: Service
metadata:
  name: aqua-csp
  labels:
    app: aqua-csp
spec:
  ports:
    - port: 443
      protocol: TCP
      targetPort: 8443
      name: aqua-web-ssl
    - port: 80
      protocol: TCP
      targetPort: 8080
      name: aqua-web
    - port: 3622
      protocol: TCP
      targetPort: 3622
      name: aqua-gateway
  selector:
    app: aqua-csp
  type: LoadBalancer
---
apiVersion: v1
kind: DeploymentConfig
metadata:
  name: aqua-csp
spec:
#  nodeSelector:
#    aqua-role: csp
  template:
    metadata:
      labels:
        app: aqua-csp
    spec:
      serviceAccount: aqua-sa
      imagePullSecrets:
        - name: dockerhub
      containers:
      - name: aqua-csp
        image: registry.aquasec.com/csp:$aquacsptag
        securityContext:
          privileged: true
        env:
          - name: SCALOCK_GATEWAY_PUBLIC_IP
            value: "aqua-csp.aqua.svc.cluster.local"
          - name: SCALOCK_GATEWAY_NAME
            value: "aqua-csp.aqua.svc.cluster.local"
          - name: BATCH_INSTALL_NAME
            value: "default"
          - name: BATCH_INSTALL_TOKEN
            value: "aqua-csp"
          - name: BATCH_INSTALL_GATEWAY
            value: "csp"
          - name: BATCH_INSTALL_ENFORCE_MODE
            value: "n"
          - name: ADMIN_PASSWORD
            valueFrom:
              secretKeyRef: 
                name: aquaadminpass
                key: password
          - name: LICENSE_TOKEN
            valueFrom:
              secretKeyRef:
                name: aqualicense
                key: license
        ports:
          - containerPort: 3622
          - containerPort: 8080
          - containerPort: 8443
        volumeMounts:
          - mountPath: /var/lib/postgresql/data
            name: aquadb-datavolume
          - mountPath: /var/run/docker.sock
            name: docker-socket-mount
      volumes:
        - name: docker-socket-mount
          hostPath:
            path: /var/run/docker.sock
        - name: aquadb-datavolume
          persistentVolumeClaim:
            claimName: aquadb-pvc
  replicas: 1
  triggers:
    - type: "ConfigChange"
EOF

#select node to deploy, and label it
#oc get nodes -o=name | sed 's/nodes[/]/ > /'
#oc get nodes | grep -v 'master' | awk '{ print $1 }'
#echo ""
#echo "From the list above, please copy and paste the node you would like to install on: "
#read -p "> " nodeselect
#oc label nodes $nodeselect aqua-role=csp --overwrite > /dev/null

# create the ds
oc create -f aqua-csp.yml

#maybe we don't need this ..  OC delete project takes care of everything anyways
echo aqua-csp.yml >> .aqualist
echo " Building... "
sleep 5
echo ""

# Aqua deployment done, just waiting for orchestrator to do its thing
echo "> Waiting for Aqua CSP Pods to come up... "
results=$(oc get pods | grep 'ContainerCreating\|Pending')
count=0
while [[ ! -z "$results" && $count -lt 15 ]];
  do
   echo -ne "*"
   sleep 2
   results=$(oc get pods | grep 'Pending\|ContainerCreating')
   let "count++"
done

echo ""

results2=$(oc get pods | grep 'ImagePullBackOff\|ErrImagePull')

if [[ ! -z $results2 ]]
  then
    echo " Houston, we have a problem...."
    echo " It's taking longer than expected, or we found an error. "
    echo ""
    oc get po | grep 'ImagePullBackOff\|ErrImagePull'
    echo ""
    echo "run oc describe on the pod above that's having the error"
    echo "note: some issue can be fixed by pulling the csp images on the other nodes"
    echo "by running sudo docker pull name-of-image:tag"
    echo ""
    echo " ********* Script exited in an error state *********"
    echo "" 
  else

   #expose the external route
    oc describe $(oc get po -o name) | grep Node:
    echo ""
    read -p " Please enter the External Route FQDN of the node listed above: " nodefqdn
    oc expose svc aqua-csp --hostname=$nodefqdn --port=aqua-web > /dev/null

    echo ""
    echo "######################################################################"
    echo ""
    echo "                        Yippie!                                     "
    echo "          Aqua was successfully installed!                          "
    echo "	You can now get to you Aqua CSP Web interface on : "
    echo ""
    echo "	> " $nodefqdn
    echo ""
    echo "######################################################################"
    echo ""
fi