#!/bin/bash
# Aqua Enterprise Install Script for demo / PoC Only
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
echo " *      Removing Aqua Enterprise from your system now.        * " 
echo " ************************************************************** "
echo ""

 kubectl delete -f aqua-csp.yaml --force -n aqua
 kubectl delete secret aqua-db dockerhub psql-password azurereg aqualicense aquapassword --force -n aqua
 kubectl delete pv aquadb-pv --force -n aqua
 kubectl delete pvc aquadb-pvc --force -n aqua

echo " "
echo " ******************************************************************* "
echo " *    Aqua Enterprise has been removed from your system now.       * " 
echo " *  You should remove the label from the node manually by          * "
echo " *   >  kubectl label node NODENAME aqua-                          * "
echo " ******************************************************************* "
echo ""