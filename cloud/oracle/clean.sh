#!/usr/bin/env bash
set -euo pipefail
set -x

OCI_TENANCY_NAME="colemickens"
OCI_TENANCY_OCID="ocid1.tenancy.oc1..aaaaaaaafyqmgtgi5nwkolwjujayjrx5qw2qmzpbp7wzche2kgmdrlptnj4q"
OCI_CMPT_ID="$1"

OCI_CMPT_NAME=$(oci iam compartment get -c ${OCI_CMPT_ID} | jq  '.data.name')

echo Compartment being deleted is ${OCI_CMPT_NAME} for 4 regions SJC, PHX, IAD and BOM.

declare -a region_codes=("SJC" 
            "PHX" "IAD"
            "BOM"
            ) # list of region codes where cmpt resources exists

for OCI_REGION_CODE in "${region_codes[@]}"
do
    UNIQUE_STACK_ID=$(date "+DATE_%Y_%m_%d_TIME_%H_%M") 

    OCID_CMPT_STACK=$(oci resource-manager stack create-from-compartment --compartment-id ${OCI_TENANCY_OCID} \
    --config-source-compartment-id ${OCI_CMPT_ID} \
    --config-source-region ${OCI_REGION_CODE} --terraform-version "1.0.x"\
    --display-name "Stack_${UNIQUE_STACK_ID}_${OCI_REGION_CODE}" --description "Stack From Compartment ${OCI_CMPT_NAME} for region ${OCI_REGION_CODE}" --wait-for-state SUCCEEDED --query "data.resources[0].identifier" --raw-output)
    
    echo $OCID_CMPT_STACK

    oci resource-manager job create-destroy-job  --execution-plan-strategy 'AUTO_APPROVED'  --stack-id ${OCID_CMPT_STACK} --wait-for-state SUCCEEDED --max-wait-seconds 300
    # twice since it fails sometimes and running it twice and is idempotent
    oci resource-manager job create-destroy-job  --execution-plan-strategy 'AUTO_APPROVED'  --stack-id ${OCID_CMPT_STACK} --wait-for-state SUCCEEDED --max-wait-seconds 540
    
    oci resource-manager stack delete --stack-id ${OCID_CMPT_STACK} --force --wait-for-state DELETED

done            

oci iam compartment delete -c ${OCI_CMPT_ID} --force --wait-for-state SUCCEEDED