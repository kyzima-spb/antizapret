#!/usr/bin/env bash

set -e

hostsFile=${1:-'config/include-hosts-custom.txt'}
excludeFile=${2:-'config/exclude-hosts-dist.txt'}
tempFile="$(mktemp)"

echo -n "Removes hosts from ${excludeFile} if they exists in ${hostsFile}..."
grep -Fvxf "$hostsFile" "$excludeFile" > "$tempFile"
mv "$tempFile" "$excludeFile"
echo '[OK]'

exit 0
