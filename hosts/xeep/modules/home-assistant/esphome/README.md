# esphome notes

## todo

1. convert directly to the esphome build
  a. generate empty esphome ahead of time
  b. copy to rpi w/ raspbian SD card
  c. drop in directory as payload for tuya-convert
2. create a template for new device bring-up on our network
3. encrypt the wifi password, include it via yaml, then rotate wifi password

## tuya-convert -> tasmota -> esphome

1. use existing raspbian sd card with software installed
2. flash tasmota
3. connect to tasmota wifi, put it on chimera-wifi
4. enable tasmota -> esphome conversion
  a. connect to web ui
  b. navigate to "console"
  c. "SetOption78 1"
  d. reboot
5. generate esphome img build
  a. 
  b. 
  c. 
7. flash esphome build
8. re-flash from esphome to confirm e2e ota esphome works