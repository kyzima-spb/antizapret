#!/usr/bin/env bash

set -e

url='https://raw.githubusercontent.com/xtrime-ru/antizapret-vpn-docker/master/include-hosts-custom.txt'
hostsFile=${1:-'config/include-hosts-custom.txt'}
tempFile="$(mktemp)"

echo -n 'Update custom hosts...'
( curl -s "$url"; echo '' ; cat "$hostsFile" ) | sort -u | grep -v '^\s*$' > "$tempFile"
mv "$tempFile" "$hostsFile"
echo '[OK]'

exit 0
