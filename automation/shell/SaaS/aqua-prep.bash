#!/bin/bash
# Enforcer Install Script for demo / PoC Only
# Please don't use this for production environment
# First run: chmod +x NAMEOFSCRIPT.sh
# Use of this script comes with no warranty
# For support with this script, contact your aqua solutions architect
# Thanks you for trying Aqua Security for all your container security needs
# Updated 7/29/2018 KZ

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
echo "#                  Version 0.9 Aqua Enterprise                #"
echo "###############################################################"
echo ""
# Pull down the images from AquaSec
read -p "Enter your Aqua Security Username (your corporate e-mail address): " USERNAME
read -p "Enter your Aqua Security Password: " -s PASSWORD
echo ""
oc new-project aqua-security
oc adm policy add-cluster-role-to-user cluster-admin admin > /dev/null
# Ask what version of Aqua to install
read -p "What version of Aqua tag do you want to Download & deploy: " aquatag

echo "Login into Openshift as admin user"
oc login
wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-agent-${aquatag}.tar.gz
echo ""
echo " **** Completed downloading the images ****"
echo ""
echo " **** Now loading images into docker **** "
sudo docker load -i aquasec-agent-${aquatag}.tar.gz
echo ""
read -p  "Enter your openshift registry address (e.g. docker-registry.default.svc:5000): " REG_PREFIX
echo ""
echo " **** Starting to Tag the images **** "
sudo docker tag aquasec/enforcer:${aquatag} ${REG_PREFIX}/aqua-security/enforcer:${aquatag}
echo ""
echo "**** Pushing images to registry **** "
sudo docker login ${REG_PREFIX} -u $(oc whoami) -p $(oc whoami -t)
sudo docker push ${REG_PREFIX}/aqua-security/enforcer:${aquatag}

echo ""
echo " Completed pushing images into registry "
echo ""