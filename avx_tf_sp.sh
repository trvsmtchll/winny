#!/bin/sh
#############################################################################################################################
# Author - Travis Mitchell Aug 11th 2020
#
# Creates Azure SP avx_bootstrap_tf_sp as pre-req for Azure Terraform Aviatrix Controller build
#  
# This script was designed for mac
#
#############################################################################################################################
export DATE=`date '+%Y%m%d%hh%s'`
export LOG_DIR=$HOME/avx-azure-arm
mkdir -p ${LOG_DIR}

##################################
# Set up logfile
##################################
LOG_FILE=${LOG_DIR}/${DATE}_avx_az_arm.log

echo "###################################################################################"
echo "Aviatrix Azure Terraform SP started at `date`" 
echo "###################################################################################"
echo "Please Wait ..."

if ! [ -x "$(command -v az)" ]; then
  echo 'Error: Azure CLI is not installed.. Try brew install azure-cli' >&2 >> $LOG_FILE
  exit 1
fi

if ! [ -x "$(command -v jq)" ]; then
  echo 'Error: jq is not installed.. Try brew install jq' > $LOG_FILE >&2
  exit 1
fi

echo "Azure CLI and jq installed" 

echo "###################################################################################"
echo "Setting up Azure Aviatrix TF Service Princpal with Contributor role"
echo "###################################################################################"

read -p "Enter Aviatrix TF Service Princpal Name (This is a user friendly name for you): "  appname
#appname="avx_bootstrap_tf_sp5" # pass in as a variable if you want
echo "Aviatrix Azure Terraform SP is $appname"
echo "This can be found in Azure Portal - Home > Your Subscription > Access control (IAM) > Check Access > $appname"


## Subscription id
SUB_ID=`az account show | jq -r '.id'`
echo "Subscription ID:         $SUB_ID" 

## Azure SP creation
az ad sp create-for-rbac -n $appname --role contributor --scopes /subscriptions/$SUB_ID >> avx_tf_sp_$DATE.json

## Set up TF ENV VARS 
ARM_CLIENT_ID=`cat avx_tf_sp_$DATE.json | jq -r '.appId'`
ARM_CLIENT_SECRET=`cat avx_tf_sp_$DATE.json | jq -r '.password'`
ARM_SUBSCRIPTION_ID=$SUB_ID
ARM_TENANT_ID=`cat avx_tf_sp_$DATE.json | jq -r '.tenant'`

echo "###################################################################################"
echo "Creating bootstrap avx_tf_sp.env file KEEP THIS FILE AND avx_tf_sp_$DATE.json SAFE!!!!"
echo ""
echo "Set up Terraform environment any time using this command - \$ source avx_tf_sp.env"
echo ""
echo "Check your environment       - \$ env | grep ARM"
echo ""
echo "This script sources your envionment on first run in this shell"
echo ""
echo "###################################################################################"

## Write to file
echo "# Aviatrix Bootstrap SP TF VARS created on $DATE" > avx_tf_sp.env 
echo "export ARM_CLIENT_ID=$ARM_CLIENT_ID" >> avx_tf_sp.env
echo "export ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET" >> avx_tf_sp.env
echo "export ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID" >> avx_tf_sp.env
echo "export ARM_TENANT_ID=$ARM_TENANT_ID" >> avx_tf_sp.env
echo "export TF_VAR_arm_application_id=$ARM_CLIENT_ID" >> avx_tf_sp.env
echo "export TF_VAR_arm_client_secret=$ARM_CLIENT_SECRET" >> avx_tf_sp.env
echo "export TF_VAR_arm_subscription_id=$ARM_SUBSCRIPTION_ID" >> avx_tf_sp.env
echo "export TF_VAR_arm_directory_id=$ARM_TENANT_ID" >> avx_tf_sp.env

## Source env variables
source avx_tf_sp.env

## Print env variables
#echo "ARM environment variables needed for azurerm provider"
#env | grep ARM
#echo ""
#echo ""
#echo "TF_VAR environment variables needed to create azure access account in Aviatrix controller"
#env | grep TF_VAR
echo ""
echo "Now you can launch the Aviatrix Controller using the Azure ARM Terraform provider"
echo ""
echo "After the Controller is launched, step2 will automate Azure SP creation and onboard Azure Access Account"


