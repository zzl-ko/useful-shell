#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Oscar<zrzxlfe@sina.com>
# Date    : 2015-1-16
# Version : v0.1
# Abstract: config samba under linux
# Usages  : None
# History : Please check the end of file.
###############################################################################

echo "this is a script to configure samba account for you."

#安装Samba相关组件
#samba: samba核心组件
#smbclient: samba客户端，用于访问其它共享文件(包括Windows的共享文件夹，同时可类似Linux的mount)
apt-get install samba smbclient

#smbfs(有的已更名为cifs-utils): 支持SMB/CIFS(如Windows)协议的文件系统
#此为一个数组,元素之间必须用空格分割,可使用(id 用户名)命令查看用户所属组
fss=(smbfs cifs-utils smbnetfs)
for fs in ${fss[@]}; do
	echo "you will install ["$fs"] file system protocol?(y/n)"
	read input
	case "$input" in
		y | Y | yes | Yes)
			apt-get install "$fs"
			;;
		*)
			;;
	esac
done

echo "select config-tool(t: \"only text\", u: \"only ui\", a: \"all\")":
read input
case "$input" in
	t)
		apt-get install samba-common samba-common-bin
		;;
	u)
		apt-get install system-config-samba
		;;
	a)
		apt-get install samba-common samba-common-bin system-config-samba
		;;
	*)
		;;
esac

if [ "-a" = "$1" ]; then #add a samba user
	echo "please input your username:"
	read username
	adduser $username sambashare
	echo "please input the absolute path of your share folders:"
	read abspath
	viewshare="${abspath##*/}"
	echo -e "[$viewshare]\n\tpath = $abspath\n\twriteable = yes\n;\tbrowseable = yes\n\tvalid users = $username\n" >> /etc/samba/smb.conf
	echo "then please input your password of the samba:"
	smbpasswd -a $username
	echo "OK! please wait for samba restart ..."
	service smbd restart
elif [ "-m" = "$1" ]; then #用图形界面方式配置
	echo "opening a gui of manage,you can manual configure."
	system-config-samba
	echo "OK! please wait for samba restart ..."
	service smbd restart
else
	echo "do nothing!"
fi

exit 0

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Oscar   2015-1-16   v0.1       Initial version create
###############################################################################