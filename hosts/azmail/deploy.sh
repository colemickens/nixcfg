export AZURE_LOCATION="westus2"
export DATA_DISK_ID="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/AZMAILDATA/providers/Microsoft.Compute/disks/azmaildata"
export DISK_ATTR="../..#images.azmail"
export IMAGE_GROUP="azmailimage"
export IMAGE_NAME="azmailimage.vhd"
export MACHINE_GROUP="azmail"
export MACHINE_NAME="azmail"

export AZURE_VM_SIZE="Standard_D2as_v4"

export AZURE_VM_OS_DISK_SIZE="128";
export AZURE_EPHEMERAL_DISK="false"
export AZURE_ACCEL_NIC="false"
export AZURE_STORAGE_SKU="Premium_LRS"

export AZURE_PUBLIC_IP="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azmaildata/providers/Microsoft.Network/publicIPAddresses/azmailpublicip"

../azdev/deploy-common.sh
