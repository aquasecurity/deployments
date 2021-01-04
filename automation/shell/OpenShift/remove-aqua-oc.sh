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
echo "            Secure once, Run Anywhere                          " 
echo "" 
echo " ************************************************************** "
echo " *       Removing Aqua from your system now.                  * " 
echo " ************************************************************** "
echo ""

oc delete project aqua
oc delete pv aquadb-pv
echo ""
echo "Please wait while all pods are being terminated."

echo " "
echo " ******************************************************************* "
echo " *       Aqua has been removed from your system now.               * " 
echo " *  Note:  it might  take a few minutes to terminate the pods      *"
echo " ******************************************************************* "
echo ""