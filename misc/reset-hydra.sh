#!/usr/bin/env bash

set -x

sudo systemctl stop hydra-server
sudo systemctl stop postgresql

sleep 1

sudo rm -rf /var/lib/postgresql
sudo rm -rf /var/lib/hydra

sleep 1

sudo systemctl restart postgresql
sudo systemctl restart hydra-init
sudo systemctl restart hydra-server
sudo systemctl restart hydra-evaluator
sudo systemctl restart hydra-queue-runner
sudo systemctl restart hydra-send-stats

sleep 1

sudo -u hydra -- hydra-create-user alice --full-name 'Alice Q. User' \
    --email-address 'alice@example.org' --password foobar --role admin

