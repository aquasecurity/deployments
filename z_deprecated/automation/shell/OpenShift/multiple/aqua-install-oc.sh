#!/bin/bash
# Install Script for demo / PoC Only
# Please don't use this for production environment
# Use of this script comes with no warranty
# For support with this script, contact your local solutions architect
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
echo "#      Welcome to the Aqua Install Script for OpenShift       #"
echo "#           This is only for Demo/PoC purpose only            #"
echo "#          Use of this script comes with no warranty          #"
echo "#                       Version 0.9                           #"
echo "###############################################################"
echo ""


# Pull down the images from AquaSec
read -p "Enter your Aqua Security Username (your corporate e-mail address): " USERNAME
read -p "Enter your Aqua Security Password: " -s PASSWORD
echo ""

# Ask what version of Aqua to install
read -p "What version of Aqua tag do you want to Download & deploy: " aquatag
# Ask if the images are already loaded
dl="no"
echo "Are the ${aquatag} images already loaded to your registry?"
select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Ok, great.  Going to the next step then." ; dl="yes"; break;;
        No ) echo "Ok , will start to downlaod and load the images to your registery."; dl="no"; exit;;
    esac
done


oc new-project aqua > /dev/null 
oc project aqua > /dev/null
oc adm policy add-cluster-role-to-user cluster-reader system:serviceaccount:aqua:aqua-sa > /dev/null
oc adm policy add-scc-to-user privileged system:serviceaccount:aqua:aqua-sa > /dev/null

if [ ${dl} == "no" then

    echo "Login into Openshift as admin user"
    oc login

    wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-console-${aquatag}.tar.gz
    wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-gateway-${aquatag}.tar.gz
    wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-database-${aquatag}.tar.gz
    wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-scanner-${aquatag}.tar.gz
    wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-enforcer-${aquatag}.tar.gz
    #wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-all-in-one-${aquatag}.tar.gz
    #wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/cybercenter-offline/latest/aquasec-cybercenter-standard-latest.tar.gz

    echo ""
    echo " **** Completed downloading the images ****"
    echo ""
    echo " **** Now loading images into docker **** "
    sudo docker load -i aquasec-console-${aquatag}.tar.gz
    sudo docker load -i aquasec-gateway-${aquatag}.tar.gz
    sudo docker load -i aquasec-database-${aquatag}.tar.gz
    sudo docker load -i aquasec-scanner-${aquatag}.tar.gz
    sudo docker load -i aquasec-enforcer-${aquatag}.tar.gz
    #sudo docker load -i aquasec-csp-${aquatag}.tar.gz
    #sudo docker load -i aquasec-cybercenter-standard-latest.tar.gz

    echo "Listing all of Aqua Images"
    sudo docker images | grep aqua

    echo "***** Completed loading images"
    echo ""
    read -p  "Enter your openshift registry address (e.g. docker-registry.default.svc:5000): " REG_PREFIX
    echo ""
    echo " **** Starting to Tag the images **** "
    sudo docker tag registry.aquasec.com/scanner:${aquatag} ${REG_PREFIX}/aqua/scanner:${aquatag}
    sudo docker tag registry.aquasec.com/database:${aquatag} ${REG_PREFIX}/aqua/database:${aquatag}
    sudo docker tag registry.aquasec.com/gateway:${aquatag} ${REG_PREFIX}/aqua/gateway:${aquatag}
    sudo docker tag registry.aquasec.com/console:${aquatag} ${REG_PREFIX}/aqua/console:${aquatag}
    sudo docker tag registry.aquasec.com/enforcer:${aquatag} ${REG_PREFIX}/aqua/enforcer:${aquatag}
    echo ""
    echo "**** Pushing images to registry **** "



    oc adm policy add-cluster-role-to-user cluster-admin admin > /dev/null


    sudo docker login ${REG_PREFIX} -u $(oc whoami) -p $(oc whoami -t)
    sudo docker push ${REG_PREFIX}/aqua/scanner:${aquatag}
    sudo docker push ${REG_PREFIX}/aqua/database:${aquatag}
    sudo docker push ${REG_PREFIX}/aqua/gateway:${aquatag}
    sudo docker push ${REG_PREFIX}/aqua/console:${aquatag}
    sudo docker push ${REG_PREFIX}/aqua/enforcer:${aquatag}

else
    read -p  "Enter your openshift registry address (e.g. docker-registry.default.svc:5000): " REG_PREFIX
    echo ""
    echo "****************************************************************"
    echo "*                  Deploying Aqua Now                         *"
    echo "****************************************************************"

fi


# Creating the Aqua Account yaml file
cat << EOF >> aqua-account.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aqua-sa
  namespace: aqua
#imagePullSecrets:
#- name: dockerhub
EOF

cat << EOF >> aqua-pv.yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: aqua-pv
  labels:
  app: aqua-database
spec:
  storageClassName: local-storage
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/tmp/aqua-database/"
EOF


cat << EOF >> aqua-pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: aqua-pvc
  app: aqua-database
spec:
  storageClassName: local-storage
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
  volumeName: "aqua-pv"
EOF

cat << EOF >> aqua-database-dc.yaml
apiVersion: v1
kind: Service
metadata:
  name: aqua-database
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
---
apiVersion: v1
kind: DeploymentConfig
metadata:
  name: aqua-database
spec:
  nodeSelector:
    aqua-db: "true"
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
        image: ${REG_PREFIX}/aqua/database:${aquatag}
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
            claimName: aqua-pvc
  replicas: 1
  triggers:
    - type: "ConfigChange"
EOF

cat << EOF >> aqua-web-dc.yaml
apiVersion: v1
kind: Service
metadata:
  name: aqua-web
  labels:
    app: aqua-web
spec:
  ports:
#    - port: 443
#      protocol: TCP
#      targetPort: 8443
#      name: aqua-web-ssl
    - port: 80
      protocol: TCP
      targetPort: 8080
      name: aqua-web
  selector:
    app: aqua-web
  type: LoadBalancer
---
apiVersion: v1
kind: DeploymentConfig
metadata:
  name: aqua-web
spec:
  template:
    metadata:
      labels:
        app: aqua-web
    spec:
      serviceAccount: aqua-sa
      containers:
      - name: aqua-web
        image: ${REG_PREFIX}/aqua/server:${aquatag}
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
        ports:
          - containerPort: 8080
#          - containerPort: 8443
        volumeMounts:
          - mountPath: /var/run/docker.sock
            name: docker-socket-mount
      volumes:
        - name: docker-socket-mount
          hostPath:
            path: /var/run/docker.sock
  replicas: 1
  triggers:
    - type: "ConfigChange"
EOF

cat << EOF >> aqua-gateway-dc.yaml
apiVersion: v1
kind: Service
metadata:
  name: aqua-gateway
  labels:
    app: aqua-gateway
spec:
  ports:
    - port: 3622
      protocol: TCP
      targetPort: 3622
      name: aqua-gateway
  selector:
    app: aqua-gateway
  type: ClusterIP
---
apiVersion: v1
kind: DeploymentConfig
metadata:
  name: aqua-gateway
spec:
  template:
    metadata:
      labels:
        app: aqua-gateway
    spec:
      serviceAccount: aqua-sa
      containers:
      - name: aqua-server
        image: ${REG_PREFIX}/aqua/gateway:${aquatag}
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
  replicas: 1
  triggers:
    - type: "ConfigChange"
EOF

echo ""
echo "logging in as System:Admin"
oc login -u system:admin > /dev/null
#Creating PSQL Password
PSQL_PWD=$(date +%s | sha256sum | base64 | head -c 32)
oc create secret generic psql-password --from-literal=psql-password=${PSQL_PWD}


# kz todo: ask if want to deploy first.
oc create -f aqua-account.yaml
oc create -f aqua-pv.yaml
oc create -f aqua-pvc.yaml
oc create -f aqua-database-dc.yaml
oc get nodes
P_DB_NODE=$(oc get nodes | grep -v Disabl | awk '/Ready/ {print $1}' | head -n 1)
read -p "Database node (default is ${P_DB_NODE}):" DB_NODE
if [ -z ${DB_NODE} ]; then DB_NODE=${P_DB_NODE}; fi
oc label node ${DB_NODE} aqua-db=true
oc create -f aqua-web-dc.yaml
oc create -f aqua-gateway-dc.yaml

echo " Here is the node aqua web is deployed to: "
oc get po -o wide | grep aqua-web

echo ""
echo " Now we need to expose the route to the aqua web service"
read -p " Enter the public (routable) FQDN: " PADDR

#oc expose svc aqua-web --name=aqua-web-route --port=aqua-web --path="/" --hostname=${PADDR}
oc expose svc aqua-web --hostname="${PADDR}" --port=aqua-web

echo ""
echo "######################################################################"
echo " Aqua Deployment completed.   Please wait for pods and svc to come online"
echo ""