#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Oscar<zrzxlfe@sina.com>
# Date    : 2015-1-16
# Version : v0.1
# Abstract: add or del account under linux
# Usages  : None
# History : Please check the end of file.
###############################################################################

echo "this is a script to configure a account for you"

if [ "$1" = "-a" ]; then
	echo "please input your username:"
	read username
	adduser $username
	echo "then please input your password:"
	#此为一个数组,元素之间必须用空格分割,可使用(id 用户名)命令查看用户所属组
	groups=(adm sudo dip plugdev lpadmin cdrom)
	for agroup in ${groups[@]}; do
		adduser $username $agroup
	done
	[ "$?" = "0" ] && echo "Successfully created an accout $username!" && exit 0
	echo "configure error!"
elif [ "$1" = "-u" ]; then
	echo "please input your username:"
	read username
	#-m创建家目录，-r创建系统账户，-s指定默认sell,-G指定所属用户组(可指定多个)
	#注：用useradd命令添加的账户具有某些隐藏属性(暂不明白),比如不能从图形界面登录
	useradd $username -mr -s /bin/bash -G adm,sudo,dip,plugdev,lpadmin,cdrom
	echo "then please input your password:"
	passwd $username 
	[ "$?" = "0" ] && echo "Successfully created an accout $username!" && exit 0
	echo "configure error!"
elif [ "$1" = "-d" ]; then
	echo "please input the username of you want to delete:"
	read username
	#use follow commands to delete user's data
	# echo "there are some file or data about $username:"
	# find / -user $username -printf {} \;
	# echo "if you want to delete all files and data about $username?(y/n)"
	# read input
	# [ "$input" = "y" -o "$input" = "Y" ] && find / -user $username -exec rm -rf {} \;
	# echo "well, next delete the homedir and passwd of $username."
	userdel $username -fr > /dev/null 2>&1
	[ "$?" = "12" ] && echo "Successfully delete an accout $username!" && exit 0
	echo "configure error!"
else
	echo "do nothing!"
fi

exit 0

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Oscar   2015-1-16   v0.1       Initial version create
###############################################################################
