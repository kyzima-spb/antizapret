#!/usr/bin/env bash
set -e

apiUrl='https://api.opennicproject.org/geoip/?bare&ipv=4&res=10'
confFile='result/opennic.conf'

echo -n 'Update OpenNIC DNS servers...'

echo 'opennic_hosts = {' > "$confFile"

curl -s "$apiUrl" | fping | awk '{if ($3 == "alive") print $1 }' | while read -r ip
do
    echo "${ip@Q}," >> "$confFile"
done

echo '}' >> "$confFile"

echo '[OK]'

exit 0
