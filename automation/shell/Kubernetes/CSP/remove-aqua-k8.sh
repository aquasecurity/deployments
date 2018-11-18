#!/bin/bash
# CSP Install Script for demo / PoC Only
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
echo " *       Removing Aqua CSP from your system now.              * " 
echo " ************************************************************** "
echo ""

 kubectl delete -f aqua-server.yaml
 #kubectl delete -f service-account.yaml
 kubectl delete secret aqua-db dockerhub
 kubectl delete pv aquadb-pv
 kubectl delete pvc aquadb-pvc
 kubectl delete -f aqua-enforcer-nodeselector.yaml

#xargs rm -f < .aqualist 
rm -f .aqualist

echo " "
echo " ******************************************************************* "
echo " *       Aqua CSP has been removed from your system now.           * " 
echo " *  You should remove the label from the node manually by          * "
echo " *   >  kubectl label node NODENAME aqua-                          * "
echo " ******************************************************************* "
echo ""