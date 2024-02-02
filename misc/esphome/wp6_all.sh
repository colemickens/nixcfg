#!/usr/bin/env bash

esphome run --no-logs wp6_sw102.yaml --device 192.168.1.166; sleep 60
esphome run --no-logs wp6_sw103.yaml --device 192.168.1.229; sleep 60
esphome run --no-logs wp6_btn104.yaml --device 192.168.1.193; sleep 60
esphome run --no-logs wp6_sw105.yaml --device 192.168.1.195; sleep 60
esphome run --no-logs wp6_sw106.yaml --device 192.168.1.176; sleep 60
esphome run --no-logs wp6_sw107.yaml --device 192.168.1.197; sleep 60
esphome run --no-logs wp6_sw108.yaml --device 192.168.1.198; sleep 60
esphome run --no-logs wp6_sw109.yaml --device 192.168.1.217; sleep 60
