export AZURE_LOCATION="westus2"
export DATA_DISK_ID="/subscriptions/aff271ee-e9be-4441-b9bb-42f5af4cbaeb/resourceGroups/AZMAILDATA/providers/Microsoft.Compute/disks/azmaildata"
export DISK_ATTR="../..#images.azmail"
export PERSIST_GROUP="azmaildata"

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

NSG="azmail_nsg"
if ! az network nsg show -g "${PERSIST_GROUP}" -n "${NSG}"; then
  az network nsg create -g "${PERSIST_GROUP}" -n "${NSG}"
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_ssh" --protocol tcp --priority 1000 --destination-port-range 22
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_http"  --protocol tcp --priority 1010 --destination-port-range 80
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_https" --protocol tcp --priority 1001 --destination-port-range 443

  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_smtp"         --protocol tcp --priority 1002 --destination-port-range 25
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_sub_tls"      --protocol tcp --priority 1003 --destination-port-range 465
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_sub_starttls" --protocol tcp --priority 1004 --destination-port-range 587

  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_imap_tls"      --protocol tcp --priority 1005 --destination-port-range 993
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_pop3_tls"      --protocol tcp --priority 1006 --destination-port-range 995
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_imap_starttls" --protocol tcp --priority 1007 --destination-port-range 143
  az network nsg rule create --resource-group "${PERSIST_GROUP}" --nsg-name "${NSG}" --name "allow_pop3_starttls" --protocol tcp --priority 1008 --destination-port-range 110
fi

export AZURE_NSG="$(az network nsg show -g "${PERSIST_GROUP}" -n "${NSG}" -o tsv --query '[id]')"

../azdev/deploy-common.sh
