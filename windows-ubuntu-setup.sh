#!/bin/sh
#############################################################################################################################
# Author - Travis Mitchell Aug 11th 2020
# Installs packages for Ubuntu machine (for Windows users)
#############################################################################################################################

# Install azure cli
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install jq
sudo apt-get install -y jq 
sudo apt-get install -y unzip

# Install Terraform
wget https://releases.hashicorp.com/terraform/0.12.29/terraform_0.12.29_linux_amd64.zip
sudo unzip ./terraform_0.12.29_linux_amd64.zip -d /usr/local/bin/

echo "Terraform installed"
terraform -v

# Prompt user to login
echo "Type az login to authenticate with Azure console"