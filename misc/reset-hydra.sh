#!/usr/bin/env bash

set -x

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

sudo -u hydra -- hydra-create-user 'cole' --full-name 'cole' \
    --email-address 'cole.mickens@gmail.com' --password cole --role admin

