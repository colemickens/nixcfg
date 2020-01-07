#!/usr/bin/env bash
set -x
DIR="${HOME}/.local/sway/sway-rdp"

export WLR_RDP_TLS_CERT_PATH="${DIR}/tls.crt"
export WLR_RDP_TLS_KEY_PATH="${DIR}/tls.key"
export WLR_RDP_ADDRESS=0.0.0.0
#export WLR_RDP_PORT=3389 # TODO: https://github.com/swaywm/wlroots/issues/1883
unset WLR_RDP_PORT

export WLR_BACKENDS=rdp

if [[ ! -f "${WLR_RDP_TLS_CERT_PATH}" ]]; then
  rm -rf "${WLR_RDP_TLS_KEY_PATH}" "${WLR_RDP_TLS_CERT_PATH}"
  openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    -keyout "${DIR}/tls.key"  -out "${DIR}/tls.crt"
fi

rm -rf "${HOME}/.local/sway/sway-rdp/sway.log"
rm -rf "${HOME}/.local/sway/sway-rdp/sway.dump"

unset WLR_RDP_PORT

#curl "https://raw.githubusercontent.com/swaywm/sway/master/config.in" > "${HOME}/.config/sway/config-stock"
sway -c "${HOME}/.config/sway/config-stock" -d &> "${HOME}/.local/sway/sway-rdp/sway.log"
sleep 1
coredumpctl dump > "${HOME}/.local/sway/sway-rdp/sway.dump"

