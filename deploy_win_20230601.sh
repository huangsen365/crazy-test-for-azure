#!/bin/bash

# Variables
TIMESTAMP=$(date +"%Y%m%d%H%M")
LOCATION="westus3"
NETWORK_INTERFACE_NAME="vm${TIMESTAMP}_z3"
NETWORK_SECURITY_GROUP_NAME="vm${TIMESTAMP}-nsg"
VIRTUAL_NETWORK_NAME="vm${TIMESTAMP}-vnet"
PUBLIC_IP_ADDRESS_NAME="vm${TIMESTAMP}-ip"
VIRTUAL_MACHINE_NAME="vm${TIMESTAMP}"
VIRTUAL_MACHINE_RG="vm${TIMESTAMP}_group"
ADMIN_USERNAME="azureuser"
VIRTUAL_MACHINE_SIZE="Standard_B4ms"
OS_DISK_TYPE="Premium_LRS"
COMPUTER_NAME="vm${TIMESTAMP}"

# Generate a random password for the admin account
ADMIN_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32)

# Create and configure the resources
az group create --name "$VIRTUAL_MACHINE_RG" --location "$LOCATION"
az network nsg create --name "$NETWORK_SECURITY_GROUP_NAME" --resource-group "$VIRTUAL_MACHINE_RG" --location "$LOCATION"
az network nsg rule create --name "RDP" --nsg-name "$NETWORK_SECURITY_GROUP_NAME" --priority 300 --resource-group "$VIRTUAL_MACHINE_RG" --access "Allow" --protocol "Tcp" --direction "Inbound" --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range "3389"
az network vnet create --name "$VIRTUAL_NETWORK_NAME" --resource-group "$VIRTUAL_MACHINE_RG" --location "$LOCATION" --address-prefixes "10.1.0.0/16"
az network vnet subnet create --name "default" --vnet-name "$VIRTUAL_NETWORK_NAME" --resource-group "$VIRTUAL_MACHINE_RG" --address-prefixes "10.1.0.0/24"
az network public-ip create --name "$PUBLIC_IP_ADDRESS_NAME" --resource-group "$VIRTUAL_MACHINE_RG" --location "$LOCATION" --allocation-method "Static" --sku "Standard" --zone "3"
az network nic create --name "$NETWORK_INTERFACE_NAME" --resource-group "$VIRTUAL_MACHINE_RG" --location "$LOCATION" --subnet "default" --vnet-name "$VIRTUAL_NETWORK_NAME" --public-ip-address "$PUBLIC_IP_ADDRESS_NAME" --network-security-group "$NETWORK_SECURITY_GROUP_NAME"
az vm create --name "$VIRTUAL_MACHINE_NAME" --resource-group "$VIRTUAL_MACHINE_RG" --location "$LOCATION" --nics "$NETWORK_INTERFACE_NAME" --image "MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest" --admin-username "$ADMIN_USERNAME" --admin-password "$ADMIN_PASSWORD" --size "$VIRTUAL_MACHINE_SIZE" --os-disk-name "$VIRTUAL_MACHINE_NAME-osdisk" --os-disk-caching "ReadWrite" --storage-sku "$OS_DISK_TYPE" --computer-name "$COMPUTER_NAME" --enable-agent true --zone "3"

# Get the public IP address of the virtual machine
vm_public_ip=$(az network public-ip show --name "$PUBLIC_IP_ADDRESS_NAME" --resource-group "$VIRTUAL_MACHINE_RG" --query "ipAddress" -o tsv)

echo "Virtual machine has been created. You can access it using the following details:"
echo "Public IP address: $vm_public_ip"
echo "Username: $ADMIN_USERNAME"
echo "Password: $ADMIN_PASSWORD"
