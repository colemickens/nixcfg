#!/usr/bin/env bash

ssh cole@$(tailscale ip --4 xeep) curl -d 'true' -X POST "http://192.168.1.166:9111/switch/wp6_sw102_relay/turn_off"

sleep 2

ssh cole@$(tailscale ip --4 xeep) curl -d 'true' -X POST "http://192.168.1.166:9111/switch/wp6_sw102_relay/turn_on"
