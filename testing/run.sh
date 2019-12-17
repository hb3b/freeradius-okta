#!/bin/bash

echo "Server IP/Hostname:"
read SERVER

echo "Server Secret:"
read -s SECRET

echo "Username:"
read USERNAME

echo "Password:"
read -s PASSWORD

cat <<EOF > client
network={
	ssid="SSID"
	key_mgmt=WPA-EAP
	eap=PEAP
	identity="$USERNAME"
	anonymous_identity="$USERNAME"
	password="$PASSWORD"
	phase2="auth=GTC"
	phase1="peapver=0"
}
EOF

/usr/sbin/eapol_test -a "$SERVER" -c client -s "$SECRET"
