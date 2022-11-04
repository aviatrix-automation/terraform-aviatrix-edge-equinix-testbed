#!/bin/bash

if [ "$1" == "-h" ] || [[ $# -eq 0 ]] ; then
  echo
  echo 'Usage: update-cloud-init.sh cloud-init-filename.txt'
  exit 0
fi

sed -i '1s/^/#set ( $PW = "$" )\r/' $1
sed -i 's/$1$salt$Mbn.OuHIbCRWB3yXewwhv0}/'\''${PW}1${PW}salt${PW}Mbn.OuHIbCRWB3yXewwhv0'\''}/g' $1
sed -i 's/"mgmt_ip": "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\/[0-9]\{1,2\}\"/"mgmt_ip": "$PUBLIC_ADDRESS_WITH_MASK"/g' $1
sed -i 's/"mgmt_default_gateway": "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\"/"mgmt_default_gateway": "$PUBLIC_GATEWAY"/g' $1

echo
echo $1' cloud-init is updated for Equinix'