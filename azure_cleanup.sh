#!/bin/bash

# Color Codes
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}WARNING: This script will remove Azure resources!${NC}"
read -p "Are you sure you want to continue? (y/N): " proceed
if [[ ! $proceed =~ ^[Yy]$ ]]
then
    exit 1
fi

resource_groups=$(az group list --query [].name -o tsv)
resource_groups_array=($resource_groups)

if [ ${#resource_groups_array[@]} -eq 0 ]
then
    echo "There are no resource groups to remove."
    exit 1
else
    echo "The following resource groups can be removed:"
    for i in "${!resource_groups_array[@]}"; do
        if [[ ${resource_groups_array[$i]} != cloud-shell-storage-* ]]; then
            printf "[%d] %s\n" "$((i+1))" "${resource_groups_array[$i]}"
        fi
    done
    echo "[A/a] All Resource Groups (excluding cloud-shell-storage-*)"
fi

read -p "Please enter the number corresponding to the resource group you want to remove, or A/a for all (excluding cloud-shell-storage-*): " rg_choice
if [[ $rg_choice =~ ^[Aa]$ ]]
then
    read -p "Are you sure you want to remove all resource groups (excluding cloud-shell-storage-*)? (y/N): " proceed_all
    if [[ $proceed_all =~ ^[Yy]$ ]]
    then
        for rg in "${resource_groups_array[@]}"; do
            if [[ $rg != cloud-shell-storage-* ]]; then
                az group delete --name $rg --yes --no-wait
            fi
        done
        echo "All resource groups (excluding cloud-shell-storage-*) are being deleted..."
    else
        exit 1
    fi
else
    index=$((rg_choice-1))
    if [[ index -ge 0 && index -lt ${#resource_groups_array[@]} ]]
    then
        if [[ ${resource_groups_array[$index]} != cloud-shell-storage-* ]]; then
            read -p "Are you sure you want to remove the resource group ${resource_groups_array[$index]}? (y/N): " proceed_rg
            if [[ $proceed_rg =~ ^[Yy]$ ]]
            then
                az group delete --name ${resource_groups_array[$index]} --yes --no-wait
                echo "The resource group ${resource_groups_array[$index]} is being deleted..."
            else
                exit 1
            fi
        else
            echo "Cannot remove resource group ${resource_groups_array[$index]} as it is excluded from deletion."
            exit 1
        fi
    else
        echo "Invalid choice."
        exit 1
    fi
fi
