#!/bin/bash
# Enforcer Install Script for demo / PoC Only
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
echo "# Welcome to the Aqua Enforcer deployment Script for OpenShift #"
echo "#           This is only for Demo/PoC purpose only            #"
echo "#          Use of this script comes with no warranty          #"
echo "#                       Version 0.9 CSP                       #"
echo "###############################################################"
echo ""

oc project aqua > /dev/null
# Add check to see if the script ran already by check to see if aqua-enforcer-nodeselector.yaml exist or not. 
# file="aqua-enforcer-nodeselector.yaml"
# if [ -f "$file" ]
# then
#  oc get nodes -o=name | sed 's/nodes[/]/ > /'
#  echo ""
#  read -p "From the list above, please copy and paste the other node you would like to install the enforcer on: " nodeselect
#  oc label nodes $nodeselect aqua-enforcer=yes
#  echo ""
#  echo "###################################################################################"
#  echo ""
#  echo "     The addtional Aqua Node Enforcer has been installed!                          "
#  echo " for more information on the Aqua Node Enforcer, visit our documents page :        "
#  echo " https://docs.aquasec.com/docs/aqua-install-openshift#section-aqua-agent-deployment"
#  echo ""
#  echo "###################################################################################"
#  echo " "
# exit 1
# else
#	echo " "
#fi

read -p "What version of Aqua Enforcer do you want to install: " aquaenforcertag


# Selecting which node to install Aqua on.
oc get nodes -o=name | sed 's/nodes[/]/ > /'
echo ""
echo "From the list above, please copy and paste the node you would like to install the enforcer on: "
read -p "> " nodeselect
echo ""


cat << EOF >> aqua-enforcer-nodeselector.yaml
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: aqua-enforcer
spec:
  template:
    metadata:
      labels:
        app: aqua-enforcer
      name: aqua-enforcer
    spec:
      serviceAccount: aqua-sa
      nodeSelector:
           aqua-enforcer: "yes"
      imagePullSecrets:
      - name: dockerhub
      hostPID: true
      containers:
      - name: aqua-enforcer
        image: registry.aquasec.com/enforcer:$aquaenforcertag
        securityContext:
          privileged: true
        env:
        - name: AQUA_TOKEN
          value: aqua-csp
        - name: AQUA_SERVER
          value: aqua-csp.aqua.svc.cluster.local:3622
        - name: AQUA_LOGICAL_NAME
          value: cluster
#        - name: AQUA_NETWORK_CONTROL
#          value: "0"
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

#exeute the yaml
oc create -f aqua-enforcer-nodeselector.yaml > /dev/null

# label the node
oc label nodes $nodeselect aqua-enforcer=yes > /dev/null

#keep tabs of the files created
echo aqua-enforcer-nodeselector.yaml >> .aqualist


echo "#####################################################################################"
echo ""
echo "              Aqua Node Enforcer Installed!                         "
echo " To deploy on addtional nodes, run the following commands manually:        "
echo "       "
echo "     >  oc label nodes <NodeName> aqua-enforcer=yes "
echo ""
echo " For more information on the Aqua Node Enforcer, visit our documents page :        "
echo " https://docs.aquasec.com/docs/aqua-install-openshift#section-aqua-agent-deployment"
echo ""
echo "####################################################################################"
echo " "