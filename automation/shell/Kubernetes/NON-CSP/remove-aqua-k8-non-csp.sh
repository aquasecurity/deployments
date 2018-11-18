#!/bin/bash
# K8 All-In-One Removal Script for demo / PoC Only
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
echo "           Secure once, Run Anywhere                          "  
echo " "
echo " ************************************************************** "
echo " *       Removing Aqua from your system now.              * " 
echo " ************************************************************** "
echo ""

 kubectl delete -f aqua-account.yaml
 kubectl delete -f storage-class.yaml
 kubectl delete -f aqua-pv.yaml
 kubectl delete -f aqua-pvc.yaml
 kubectl delete -f aqua-database.yaml
 kubectl delete -f aqua-services.yaml
 kubectl delete -f aqua-web.yaml
 kubectl delete -f aqua-gateway.yaml
 kubectl delete -f aqua-cc.yaml
 kubectl delete secrets dockerhub psql-password -n aqua

 x=$(kubectl get nodes --show-labels | grep aqua | awk '{ print $1 }')
 kubectl label nodes ${x} aqua-db-

 kubectl delete namespace aqua

#to do add question to ask if we should delete the yaml files.  It would good to delete if you are going to reinstall, otherwise the yaml files won't be over written. 
 rm *.yaml
 
 echo "Removed Aqua"