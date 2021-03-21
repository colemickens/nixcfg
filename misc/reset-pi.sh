curl \
  -X POST \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $HA_TOKEN" \
  -d "{ \"entity_id\": \"switch.wp6_sw105_relay\" }" \
  'http://192.168.1.2:8123/api/services/switch/turn_off'

sleep 3

curl \
  -X POST \
  -H 'Content-Type: application/json' \
  -H "Authorization: Bearer $HA_TOKEN" \
  -d "{ \"entity_id\": \"switch.wp6_sw105_relay\" }" \
  'http://192.168.1.2:8123/api/services/switch/turn_on'

date

# while true; do true; minicom -b 155200 -D /dev/ttyUSB0; sleep 0.5; done

# while true; do true; screen /dev/ttyUSB0 115200; sleep 0.5; done