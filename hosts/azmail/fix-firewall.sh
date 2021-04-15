#!/usr/bin/env bash

set -x

az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_http"  --protocol tcp --priority 1010 --destination-port-range 80
az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_https" --protocol tcp --priority 1001 --destination-port-range 443

az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_smtp"         --protocol tcp --priority 1002 --destination-port-range 25
az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_sub_tls"      --protocol tcp --priority 1003 --destination-port-range 465
az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_sub_starttls" --protocol tcp --priority 1004 --destination-port-range 587

az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_imap_tls"      --protocol tcp --priority 1005 --destination-port-range 993
az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_pop3_tls"      --protocol tcp --priority 1006 --destination-port-range 995
az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_imap_starttls" --protocol tcp --priority 1007 --destination-port-range 143
az network nsg rule create --resource-group "azmail" --nsg-name "azmailNSG" --name "allow_pop3_starttls" --protocol tcp --priority 1008 --destination-port-range 110
