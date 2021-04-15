export AZURE_LOCATION="westus2"
export DATA_DISK_ID=/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/azdev2020data/providers/Microsoft.Compute/disks/datadisk
export DISK_ATTR="../..#images.azdev"
export IMAGE_GROUP="azdev2020nov"
export IMAGE_NAME="azdev-21.03.20210129.711d6c9-b6807db8.vhd"
export MACHINE_GROUP="azdev2020vm1"
export MACHINE_NAME="azdev2020vm1"

export AZURE_VM_SIZE="Standard_D4as_v4"

export AZURE_VM_OS_DISK_SIZE="128";
export AZURE_EPHEMERAL_DISK="false"
export AZURE_STORAGE_SKU="Premium_LRS"

../azdev/deploy-common.sh
