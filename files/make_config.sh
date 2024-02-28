#!/bin/bash

# Argument 1: Client identifier

EASY_RSA_DIR=~/easy-rsa
KEY_DIR=~/client-configs/keys
OUTPUT_DIR=~/client-configs/files
BASE_CONFIG=~/client-configs/base.conf

cd ${EASY_RSA_DIR}
./easyrsa gen-req "${1}" nopass
cp pki/private/"${1}".key ~/client-configs/keys/
./easyrsa sign-req client "${1}"
cp pki/issued/"${1}".crt ~/client-configs/keys

cat ${BASE_CONFIG} \
    <(echo -e '<ca>') \
    ${KEY_DIR}/ca.crt \
    <(echo -e '</ca>\n<cert>') \
    ${KEY_DIR}/${1}.crt \
    <(echo -e '</cert>\n<key>') \
    ${KEY_DIR}/${1}.key \
    <(echo -e '</key>\n<tls-crypt>') \
    ${KEY_DIR}/ta.key \
    <(echo -e '</tls-crypt>') \
    > ${OUTPUT_DIR}/"${1}".ovpn
