#!/bin/bash

# Argument 1: Server IP
# Argument 2: Server port (optional)

IP=${1}
PORT="${2:-1194}"

if [ -z "$IP" ]; then
    echo "Usage:"
    echo "$ ./init.sh <IP> [<PORT>]"
    exit 1
fi

echo "Setting up the OpenVPN server at ${IP}:${PORT}"

# Pre-requisites
apt update
apt install -y openvpn easy-rsa ufw

# Server certs and keys
mkdir ~/easy-rsa
ln -s /usr/share/easy-rsa/* ~/easy-rsa/

cd ~/easy-rsa
cp ~/vpn-setup/files/vars ./vars

./easyrsa init-pki
./easyrsa gen-req server nopass
./easyrsa build-ca
./easyrsa sign-req server server
cp pki/ca.crt pki/issued/server.crt pki/private/server.key /etc/openvpn/server

openvpn --genkey --secret ta.key
cp ta.key /etc/openvpn/server

# Clients common certs and keys
mkdir -p ~/client-configs/keys
cp ta.key pki/ca.crt  ~/client-configs/keys

# OpenVPN config
cp ~/vpn-setup/files/server.conf /etc/openvpn/server/server.conf
sed -i -e "s/%PORT%/${PORT}/g" /etc/openvpn/server/server.conf
cp ~/vpn-setup/files/sysctl.conf /etc/sysctl.conf
sysctl -p

cp ~/vpn-setup/files/before.rules /etc/ufw/before.rules
cp ~/vpn-setup/files/ufw /etc/default/ufw

ufw allow "${PORT}"/udp
ufw allow OpenSSH
ufw disable
ufw enable

### Start OpenVPN
systemctl -f enable openvpn-server@server.service
systemctl start openvpn-server@server.service

# Client config generator
mkdir -p ~/client-configs/files
cp ~/vpn-setup/files/base.conf ~/client-configs/base.conf
sed -i -e "s/%IP%/${IP}/g" ~/client-configs/base.conf
sed -i -e "s/%PORT%/${PORT}/g" ~/client-configs/base.conf
cp ~/vpn-setup/files/make_config.sh ~/client-configs/make_config.sh
