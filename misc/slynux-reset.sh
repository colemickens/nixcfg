#!/usr/bin/env bash

# slynux-reset.sh
# - use the esphome plugs at remote location
# - trigger it off, then back on
# - thus resetting slynux if it got stuck

ssh cole@$(tailscale ip --4 xeep) curl -d 'true' -X POST "http://192.168.1.166:9111/switch/wp6_sw102_relay/turn_off"

sleep 2

ssh cole@$(tailscale ip --4 xeep) curl -d 'true' -X POST "http://192.168.1.166:9111/switch/wp6_sw102_relay/turn_on"
