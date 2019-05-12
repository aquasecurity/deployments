#!/bin/bash
# Enforcer Install Script for demo / PoC Only
# Please don't use this for production environment
# First run: chmod +x NAMEOFSCRIPT.sh
# Use of this script comes with no warranty
# For support with this script, contact your aqua solutions architect
# Thanks you for trying Aqua Security for all your container security needs
# Updated 7/31/2018 KZ

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

read -p "What version of Aqua Enforcer tag do you want to install: " aquatag
read -p "What is your Aqua SaaS instance: " saasenv

# Pull down the images from AquaSec
read -p "Enter your Aqua Security Username (your corporate e-mail address): " USERNAME
read -p "Enter your Aqua Security Password: " -s PASSWORD
echo ""

wget --user "${USERNAME}" --password "${PASSWORD}" https://download.aquasec.com/csp-images/${aquatag}/aquasec-agent-${aquatag}.tar.gz
echo ""
echo " **** Completed downloading the images ****"
echo ""
echo " **** Now loading images into docker **** "
sudo docker load -i aquasec-agent-${aquatag}.tar.gz
echo " **** Loading images Completed **** "
echo ""
docker run --rm -e SILENT=yes -e AQUA_TOKEN=LINUXPOC -e AQUA_SERVER=$saasenv -e AQUA_NETWORK_CONTROL=1 -v /var/run/docker.sock:/var/run/docker.sock aquasec/enforcer:$aquatag