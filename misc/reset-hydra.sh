#!/usr/bin/env bash

set -x
set -euo pipefail

sudo systemctl stop hydra-server
sudo systemctl stop postgresql

sleep 1

sudo find /var/lib/postgresql/ -mindepth 1 -delete
sudo find /var/lib/hydra -mindepth 1 -delete

sudo systemctl restart postgresql
sudo systemctl restart hydra-init
sudo systemctl restart hydra-server
sudo systemctl restart hydra-evaluator
sudo systemctl restart hydra-queue-runner
sudo systemctl restart hydra-send-stats

sleep 1

U=cole
sudo -u hydra -- hydra-create-user "${U}" --full-name "${U}" --email-address "${U}@hydra" --password "${U}" --role admin

sleep 2

LOGIN="{\"username\":\"cole\", \"password\": \"cole\"}"
curl -b /tmp/cookie -c /tmp/cookie -d "${LOGIN}" -X 'POST' -H 'Content-Type: application/json' --referer 'http://localhost:3000/' http://localhost:3000/login

JSON="{\"displayname\":\"nixcfg\", \"enabled\": \"1\", \"visible\": \"1\", \"decltype\": \"git\", \"declvalue\": \"https://github.com/colemickens/nixcfg main\", \"declfile\": \"spec.json\"}"
curl -b /tmp/cookie -c /tmp/cookie -d "${JSON}" -X 'PUT' -H 'Content-Type: application/json' --referer 'http://localhost:3000/' http://localhost:3000/project/nixcfg

sleep 2

sudo systemctl restart hydra-evaluator
sudo systemctl restart hydra-queue-runner
sudo systemctl restart hydra-notify

sudo -u postgres psql -c "alter user hydra with encrypted password 'hydra'";
