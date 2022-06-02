#!/bin/bash

function usage() {
	echo "parameter error!"
	echo "At least 4 parameters must be supplied!"
	echo "1st: if-name, 2nd: con-name, 3rd: ssid-name, 4th: ssid-pass"
	echo "5th parm is option, 2: 2.4G, 5: 5G"
	exit 1
}

function create_2_4G_wifi_hotspot() {
	if_name="$1"
	con_name="$2"
	ssid_name="$3"
	ssid_pass="$4"

	sudo nmcli radio wifi on
	sudo nmcli c add type wifi ifname ${if_name} con-name ${con_name} autoconnect no ssid ${ssid_name}
	sudo nmcli c modify ${con_name} 802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared
	sudo nmcli c modify ${con_name} 802-11-wireless-security.key-mgmt wpa-psk
	sudo nmcli c modify ${con_name} 802-11-wireless-security.psk ${ssid_pass}
}

function create_5G_wifi_hotspot() {
	if_name="$1"
	con_name="$2"
	ssid_name="$3"
	ssid_pass="$4"

	sudo nmcli radio wifi on
	sudo nmcli c add type wifi ifname ${if_name} con-name ${con_name} autoconnect no ssid ${ssid_name}
	sudo nmcli c modify ${con_name} 802-11-wireless.mode ap 802-11-wireless.band a 802-11-wireless.channel 149 802-11-wireless.powersave 2 ipv4.method shared
	sudo nmcli c modify ${con_name} 802-11-wireless-security.key-mgmt wpa-psk
	sudo nmcli c modify ${con_name} 802-11-wireless-security.psk ${ssid_pass}
}

function start_wifi() {
	# 停止热点
	sudo nmcli c up ${con_name}
}

function stop_wifi() {
	# 启动热点
	sudo nmcli c down ${con_name}
}

function delete_wifi() {
	# 删除热点
	sudo nmcli c delete ${con_name}
}

function main() {
	if [ $# -eq 2 ]; then
		con_name="$2"
		case $1 in
			u) start_wifi ;;
			d) stop_wifi ;;
			D) delete_wifi ;;
		esac
		exit 0
	else
		[ $# -lt 4 ] && usage
	fi

	if [ "$5" = "5" ]; then
		create_5G_wifi_hotspot $@
	else
		create_2_4G_wifi_hotspot $@
	fi

	[ $? -eq 0 ] && start_wifi
}

main $@
