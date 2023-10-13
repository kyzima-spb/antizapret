#!/usr/bin/env bash

set -e

cp result/opennic.conf /etc/knot-resolver/
cp result/knot-aliases-alt.conf /etc/knot-resolver/
systemctl restart kresd@1.service

cp result/openvpn-blocked-ranges.txt /etc/openvpn/server/ccd/DEFAULT
iptables -F azvpnwhitelist
while read -r line
do
    iptables -w -A azvpnwhitelist -d "$line" -j ACCEPT
done < result/blocked-ranges.txt

exit 0
