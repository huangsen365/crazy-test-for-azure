#!/bin/bash

# Variables
TIMESTAMP=$(date +"%Y%m%d%H%M")
LOCATION="westus3"
NETWORK_INTERFACE_NAME="vm${TIMESTAMP}_z3"
NSG_NAME="vm${TIMESTAMP}-nsg"
SUBNET_NAME="default"
VNET_NAME="vm${TIMESTAMP}-vnet"
ADDRESS_PREFIX="10.0.0.0/16"
SUBNET_PREFIX="10.0.0.0/24"
PUBLIC_IP_NAME="vm${TIMESTAMP}-ip"
PUBLIC_IP_TYPE="Static"
PUBLIC_IP_SKU="Standard"
VM_NAME="vm${TIMESTAMP}"
COMPUTER_NAME="vm${TIMESTAMP}"
RESOURCE_GROUP="group${TIMESTAMP}"
OS_DISK_TYPE="Premium_LRS"
VM_SIZE="Standard_B2s"
ADMIN_USERNAME="azureuser"
ZONE="3"

# Create a Resource Group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create a Network Security Group
az network nsg create --resource-group $RESOURCE_GROUP --name $NSG_NAME --location $LOCATION

# Add an inbound security rule to the Network Security Group for SSH
az network nsg rule create --resource-group $RESOURCE_GROUP --nsg-name $NSG_NAME --name "SSH" --priority 300 --protocol "TCP" --direction "Inbound" --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range "22" --access "Allow"

# Create a Virtual Network
az network vnet create --resource-group $RESOURCE_GROUP --name $VNET_NAME --address-prefix $ADDRESS_PREFIX --subnet-name $SUBNET_NAME --subnet-prefix $SUBNET_PREFIX --location $LOCATION

# Create a Public IP Address
az network public-ip create --resource-group $RESOURCE_GROUP --name $PUBLIC_IP_NAME --allocation-method $PUBLIC_IP_TYPE --sku $PUBLIC_IP_SKU --location $LOCATION --zone $ZONE

# Create a Network Interface
az network nic create --resource-group $RESOURCE_GROUP --name $NETWORK_INTERFACE_NAME --subnet $(az network vnet subnet show --resource-group $RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv) --public-ip-address $(az network public-ip show --resource-group $RESOURCE_GROUP --name $PUBLIC_IP_NAME --query id -o tsv) --network-security-group $(az network nsg show --resource-group $RESOURCE_GROUP --name $NSG_NAME --query id -o tsv) --location $LOCATION

# Create the Virtual Machine
az vm create --resource-group $RESOURCE_GROUP --name $VM_NAME --image "Canonical:0001-com-ubuntu-server-jammy:22_04-lts-gen2:latest" --size $VM_SIZE --os-disk-size-gb 30 --storage-sku $OS_DISK_TYPE --admin-username $ADMIN_USERNAME --generate-ssh-keys --computer-name $COMPUTER_NAME --nics $(az network nic show --resource-group $RESOURCE_GROUP --name $NETWORK_INTERFACE_NAME --query id -o tsv) --location $LOCATION --zone $ZONE
