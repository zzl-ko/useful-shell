#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Oscar<zrzxlfe@sina.com>
# Date    : 2019-08-09
# Version : v0.1
# Abstract: Touchpad of laptop on or off under ubuntu.
# Usages  :
# History : Please check the end of file.
###############################################################################

function get_touchpad_id()
{
	TouchpadId=`xinput list | grep "Touchpad" | grep -oP "(?<=id=)\d+"`

	return "$TouchpadId"
}

function enable_touchpad()
{
	xinput enable "$tid"

	echo "Toudpad id=$tid enabled"
}

function disable_touchpad()
{
	xinput disable "$tid"

	echo "Toudpad id=$tid disabled"
}

function toggle_touchpad()
{
	var=$(xinput list-props "$tid" | grep "Device Enabled")

	if   [ ${var:((${#var}-1))} == "1" ];then
	    xinput set-prop "$tid" "Device Enabled" 0
	    echo "Toudpad id=$tid disabled"
	elif [ ${var:((${#var}-1))} == "0" ];then
	    xinput set-prop "$tid" "Device Enabled" 1
	    echo "Toudpad id=$tid enabled"
	fi
}

function main()
{
	get_touchpad_id
	tid="$TouchpadId"

	if [ "$#" == "0" ]; then
		toggle_touchpad
	else
		case "$1" in
			1|e|y)
				enable_touchpad
			;;
			0|e|n)
				disable_touchpad
			;;
			*)
				toggle_touchpad
			;;
		esac
	fi
}

main

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Oscar   2019-08-09  v0.1       Initial version create
#------------------------------------------------------------------------------
# Ref: 
# https://blog.csdn.net/kellncy/article/details/53573526
# https://www.cnblogs.com/sevenskey/p/5317941.html
###############################################################################
