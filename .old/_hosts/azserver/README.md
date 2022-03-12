
# az group create -n azserver_data -l westus2
# az disk create --name 'azserver_datadisk' --resource-group 'azserver_data' --size-gb 128 --location westus2
# az group lock create --name 'azserver_datadisk_lock' --resource-group 'azserver_data' --lock-type 'CanNotDelete'

# deploy.sh

# attach the disk, modify the config, then we're okay?
