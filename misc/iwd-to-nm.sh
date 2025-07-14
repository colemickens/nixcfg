#!/usr/bin/env bash

# Mostly authored by Gemini 2.5: https://g.co/gemini/share/0fd2a7ee2099

# A script to convert iwd network profiles to NetworkManager connection files.
# This script must be run with root privileges.

interface="$1"

IWD_PROFILE_DIR="/var/lib/iwd"
NM_CONN_DIR="/tmp/system-connections"
mkdir -p "${NM_CONN_DIR}"

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root." >&2
  exit 1
fi

# Check if the iwd profile directory exists
if [ ! -d "$IWD_PROFILE_DIR" ]; then
  echo "iwd profile directory not found: $IWD_PROFILE_DIR" >&2
  exit 1
fi

# Ensure the NetworkManager connection directory exists
mkdir -p "$NM_CONN_DIR"

# Loop through all files in the iwd profile directory
for iwd_profile in "$IWD_PROFILE_DIR"/*.*; do
  if [ ! -f "$iwd_profile" ]; then
    continue
  fi

  filename=$(basename "$iwd_profile")
  ssid_part="${filename%.*}"
  security_type="${filename##*.}"

  # Decode SSID
  if [[ "$ssid_part" == =* ]]; then
    # Hex-encoded SSID
    ssid=$(echo -n "${ssid_part:1}" | xxd -r -p)
  else
    # Plain text SSID
    ssid="$ssid_part"
  fi

  echo "Processing network: $ssid"

  # Generate a UUID for the NetworkManager connection
  uuid=$(uuidgen)

  # Create the NetworkManager connection file
  nm_conn_file="$NM_CONN_DIR/$ssid.nmconnection"

  # Base connection configuration
  cat > "$nm_conn_file" <<EOF
[connection]
id=$ssid
uuid=$uuid
type=wifi
interface-name=${interface}

[wifi]
mode=infrastructure
ssid=$ssid

[ipv4]
method=auto

[ipv6]
method=auto

EOF

  # Add security settings based on the file extension
  case "$security_type" in
    "psk")
      passphrase=$(grep -E "^Passphrase=" "$iwd_profile" | cut -d'=' -f2-)
      if [ -n "$passphrase" ]; then
        cat >> "$nm_conn_file" <<EOF
[wifi-security]
key-mgmt=wpa-psk
psk=$passphrase
EOF
      else
        echo "  No passphrase found for $ssid, skipping security section."
      fi
      ;;
    "open")
      # No security section needed for open networks
      ;;
    "8021x")
      echo "  802.1x profiles are not fully supported by this script. A basic file will be created."
      # Basic 802.1x configuration, may need manual adjustment
      eap_method=$(grep -E "^EAP-Method=" "$iwd_profile" | cut -d'=' -f2-)
      identity=$(grep -E "^EAP-Identity=" "$iwd_profile" | cut -d'=' -f2-)
      password=$(grep -E "^EAP-Password=" "$iwd_profile" | cut -d'=' -f2-)

      cat >> "$nm_conn_file" <<EOF
[wifi-security]
key-mgmt=wpa-eap
EOF

      if [ -n "$eap_method" ] && [ -n "$identity" ] && [ -n "$password" ]; then
        cat >> "$nm_conn_file" <<EOF
[802-1x]
eap=$eap_method;
identity=$identity
password=$password
EOF
      fi
      ;;
    *)
      echo "  Unsupported security type: $security_type. Skipping security section."
      ;;
  esac

  # Set appropriate permissions for the NetworkManager connection file
  chmod 600 "$nm_conn_file"
  chown root:root "$nm_conn_file"

  echo "  Successfully created NetworkManager connection file: $nm_conn_file"
done

echo "Conversion complete."
