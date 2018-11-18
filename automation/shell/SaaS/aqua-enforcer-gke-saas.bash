#!/bin/bash
# Enforcer Install Script for demo / PoC Only
# Please don't use this for production environment
# First run: chmod +x NAMEOFSCRIPT.sh
# Use of this script comes with no warranty
# For support with this script, contact your aqua solutions architect
# Thanks you for trying Aqua Security for all your container security needs
# Updated 8/23/2018 KZ

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

read -p "What version of Aqua Enforcer tag do you want to install (i.e. 3.2.0): " aquatag
read -p "What is the address of your Aqua SaaS instance (i.e. saas01.aquasec.com) : " saasenv
echo ""
# Pull down the images from AquaSec
echo "We are going to download the images from Aqua now"
echo "************************************************"
read -p "Enter your Aqua Security Username (your corporate e-mail address): " USERNAME
read -p "Enter your Aqua Security Password: " -s PASSWORD
echo ""
wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-agent-${aquatag}.tar.gz
echo ""
echo " **** Completed downloading the images ****"
echo ""
echo " **** Now loading images into docker **** "
docker load -i aquasec-agent-${aquatag}.tar.gz
echo " **** Loading images Completed **** "
read -p "Enter your registry prefix (i.e. gcr.io/ProjectName): " gcrPrefix
echo ""
docker tag aquasec/agent${aquatag} ${gcrPrefix}/agent${aquatag}

regGCR = ${gcrPrefix}/agent${aquatag}
docker push ${regGCR}

echo ""
echo "************************************************"
echo "Aqua agent image loaded into your GCR registry"
echo "************************************************"
echo ""

echo "************************************************"
echo " "
echo " Please create the enforcer group in the Aqua UI with the following parameters: "
echo " Group Name:  GKE-Enforcers "
echo " Orchestrator:  Kubernetes GKE "
echo " Container Runtime:  Docker "
echo " Installation Token: AquaToken "
echo " Under Security Settings:"
echo " Enforcement Mode: Enforce"
echo " Under Auditing & Advance: All check boxes checked off "
echo " "
echo "************************************************"

cat << EOF >> aqua-enforcer.yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: aqua-agent
  namespace: 
spec:
  template:
    metadata:
      labels:
        app: aqua-agent
      name: aqua-agent
    spec:
      serviceAccount: 
      hostPID: true
      containers:
      - name: aqua-agent
        image: ${regGCR}
        securityContext:
          privileged: true
        env:
        - name: AQUA_TOKEN
          value: AquaToken
        - name: AQUA_SERVER
          value: ${saasenv}:3622
        - name: AQUA_LOGICAL_NAME
          value: 
        - name: RESTART_CONTAINERS
          value: "no"
        - name: AQUA_INSTALL_PATH
          value: /var/lib/aquasec
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
          path: /var/lib/aquasec
      - name: aquasec-tmp
        hostPath:
          path: /var/lib/aquasec/tmp
      - name: aquasec-audit
        hostPath:
          path: /var/lib/aquasec/audit
EOF

kubectl create -f aqua-enforcer.yaml

