#!/usr/bin/env bash

# AntiZapret VPN for Debian based OS installation script
# 
# See https://bitbucket.org/anticensority/antizapret-vpn-container/ for the installation steps.
# 
# wget -qO- http://192.168.88.200:8000/install.sh | sudo bash
# wget -qO- http://192.168.88.200:8000/install.sh | sudo IMAGE=test.tar.xz NAME=antizapret-test bash
# wget -qO- http://192.168.88.200:8000/install.sh | sudo bash /dev/stdin uninstall

set -e

NAME=${NAME:-'antizapret-vpn'}
IMAGE=${IMAGE:-'https://antizapret.prostovpn.org/container-images/az-vpn/rootfs.tar.xz'}


next_filename()
{
	filename="$1"

	name="${filename%%.*}"
	ext="${filename#*.}"
	number=1

	while [ -e "$filename" ]
	do
		filename="${name}_$(( number++ )).${ext}"
	done

	echo "$filename"
}


function installRequirements()
{
	apt update -qq

	if ! command -v machinectl > /dev/null
	then
		DEBIAN_FRONTEND=noninteractive apt install -qq -y systemd-container
	fi

	if ! command -v gpg > /dev/null
	then
		DEBIAN_FRONTEND=noninteractive apt install -qq -y gnupg
	fi

	gpg -k > /dev/null
	gpg \
		--no-default-keyring \
		--keyring /etc/systemd/import-pubring.gpg \
		--keyserver hkps://keyserver.ubuntu.com \
		--receive-keys 0xEF2E2223D08B38D4B51FFB9E7135A006B28E1285

	systemctl enable --now systemd-networkd.service
}


function install()
{
	local name="$1"
	local image="$2"

	if [[ -f "$image" ]]
	then
		machinectl import-tar "$image" "$name"
	else
		machinectl pull-tar "$image" "$name"
	fi

	local nspawnDir="/etc/systemd/nspawn"
	local nspawnFile="${nspawnDir}/${name}.nspawn"

	mkdir -p "$nspawnDir"
	
	if [[ ! -f "$nspawnFile" ]]
	then
		cat > "$nspawnFile" <<- EOF
			[Exec]
			NotifyReady=yes

			[Network]
			VirtualEthernet=yes
			Port=tcp:1194:1194
			Port=udp:1194:1194
		EOF
	fi

	machinectl enable "$name"
	machinectl start "$name"

	src="/root/easy-rsa-ipsec/CLIENT_KEY/antizapret-client-tcp.ovpn"
	target="$(next_filename "${name}.ovpn")"
	
	echo -n "Wait creation OVPN config file."

	while ! machinectl copy-from "$name" "$src" "$target" 2>/dev/null
	do
		echo -n '.'
		sleep 1
	done

	echo "[OK]"
	echo "OpenVPN configuration file saved to ${target}"
	
	chown $SUDO_UID:$SUDO_GID "$target"
}


function uninstall
{
	local name="$1"

	if machinectl show "$name" > /dev/null
	then
		machinectl poweroff "$name"
	fi

	if machinectl show-image "$name" > /dev/null
	then
		machinectl disable "$name"

		while ! machinectl remove "$name" 2>/dev/null
		do
			sleep 1
		done
	fi

	rm -f "/etc/systemd/nspawn/${name}.nspawn"
}


main()
{
	if [ "$(whoami)" != 'root' ]
	then
		echo >&2 "You have no permission to run $0 as non-root user. Use sudo"
		exit 1
	fi

	case "$1" in
		install|'')
			installRequirements
			install "$NAME" "$IMAGE" ;;
		uninstall)
			uninstall "$NAME" ;;
		*)
			echo >&2 'Command not found'
			exit 1
			;;
	esac
}


main $@
