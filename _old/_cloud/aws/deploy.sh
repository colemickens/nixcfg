#!/usr/bin/env bash
set -x
set -euo pipefail

# TODO: maybe we need to upload our own AMI or something? 

REGION="us-west-2"
#AMI_ID="ami-073449580ff8e82b5" #NixOS-20.03.2351.f8248ab6d9e-aarch64-linux
#AMI_ID="ami-09d0dda914bed4052" # Amazon Linux 2
AMI_ID="ami-053c71bfc2f2ae88d" # NixOS-20.09alpha417.a780c60f9f7-aarch64-linux

#INSTANCE_TYPE="m6gd.metal" # failed
#INSTANCE_TYPE="m6g.metal" # failed
INSTANCE_TYPE="m6g.8xlarge"
tag="devenv"
INDEX="1"

# TODO: aws cli can query built-in, remove jq usage

awsweeper-tag "${tag}"

vpc="$(aws ec2 create-vpc \
  --cidr-block "10.${INDEX}.0.0/16" \
  --region "${REGION}" \
  | jq -r '.Vpc.VpcId')"

sub="$(aws ec2 create-subnet \
  --vpc-id "${vpc}" \
  --region "${REGION}" \
  --cidr-block "10.${INDEX}.1.0/24" | jq -r '.Subnet.SubnetId')"

gw="$(aws ec2 create-internet-gateway --region "${REGION}" | jq -r '.InternetGateway.InternetGatewayId')"

aws ec2 attach-internet-gateway \
  --vpc-id "${vpc}" \
  --internet-gateway-id "${gw}" \
  --region "${REGION}"

rt="$(aws ec2 create-route-table --vpc-id "${vpc}" --region "${REGION}" | jq -r '.RouteTable.RouteTableId')"

aws ec2 create-route \
  --route-table-id "${rt}" \
  --destination-cidr-block 0.0.0.0/0 \
  --gateway-id "${gw}" \
  --region "${REGION}"

aws ec2 associate-route-table \
  --subnet-id "${sub}" \
  --route-table-id "${rt}" \
  --region "${REGION}"

sg="$(aws ec2 create-security-group \
  --description "${vpc}-ssh" \
  --vpc-id "${vpc}" \
  --group-name "${vpc}-ssh" \
  --region "${REGION}" | jq -r '.GroupId')"

aws ec2 authorize-security-group-ingress \
  --group-id "${sg}" \
  --protocol tcp \
  --port 22 \
  --cidr 0.0.0.0/0 \
  --region "${REGION}"

inst="$(aws ec2 run-instances \
  --image-id "${AMI_ID}" \
  --count 1 \
  --region "${REGION}" \
  --subnet-id "${sub}" \
  --security-group-id "${sg}" \
  --instance-type "${INSTANCE_TYPE}" \
  --block-device-mappings "[{\"DeviceName\": \"/dev/xvda\",\"Ebs\":{\"VolumeSize\":100,\"VolumeType\":\"gp2\"}}]" \
  --key-name "colemickens" \
  --associate-public-ip-address | jq -r '.Instances[0].InstanceId')"

aws ec2 create-tags \
  --resources "${vpc}" "${sub}" "${gw}" "${rt}" "${sg}" "${inst}" \
  --region "${REGION}" \
  --tags "Key=project,Value=${tag}"

ip="$(aws ec2 describe-instances \
  --region "${REGION}" \
  --instance-ids "${inst}" \
  --query 'Reservations[0].Instances[0].PublicIpAddress' \
  --output text)"

until ssh-keyscan -H "${ip}" >> ~/.ssh/known_hosts; do sleep 2; done

export REMOTE="root@${ip}"
until ssh -oBatchMode=yes ${REMOTE} uptime; do sleep 2; done

~/code/nixcfg/nixup build \
  '.#bundles.aarch64-linux' \
  "${REMOTE}" 'cole@localhost'
