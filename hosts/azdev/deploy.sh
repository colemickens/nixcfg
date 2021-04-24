export AZURE_LOCATION="westus2"
export DATA_DISK_ID="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020data/providers/Microsoft.Compute/disks/datadisk"
export DISK_ATTR="../..#images.azdev"
export IMAGE_GROUP="azdev2020img"
export IMAGE_NAME="azdevimg.vhd"

export MACHINE_GROUP="azdev2020vm1"
export MACHINE_NAME="azdev2020vm1"


## small size, cheap, long-running
export AZURE_VM_SIZE="Standard_D4as_v4"
export AZURE_VM_OS_DISK_SIZE="128" # this can be larger than the sku allows, since we use a non-ephemeral disk
export AZURE_STORAGE_SKU="Premium_LRS"
export AZURE_EPHEMERAL_DISK="false"
export AZURE_ACCEL_NIC="false"

## big size, boost, expensive, for intense dev seshs brah (ew, forgive me)
export AZURE_VM_SIZE="Standard_D16as_v4"
export AZURE_VM_OS_DISK_SIZE="128";
export AZURE_STORAGE_SKU="Standard_LRS" # must use standard with ephemeral os disk (it's faster tho)
export AZURE_EPHEMERAL_DISK="true"
export AZURE_ACCEL_NIC="true"

../azdev/deploy-common.sh

