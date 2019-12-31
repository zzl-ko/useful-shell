#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Oscar<zrzxlfe@sina.com>
# Date    : 2019-08-20
# Version : v0.1
# Abstract: None
# Usages  : None
# History : Please check the end of file.
###############################################################################

function init_catkin_ws()
{
    if [ -f ".catkin_workspace" ]; then
        echo "This is already a catkin workspace!"
        return 0
    fi

    if [ ! -d "`pwd`/src" ]; then
        mkdir -p ./src
    fi

    if [ -z `which catkin_init_workspace` ]; then
    	echo "No such cmd: catkin_init_workspace"
	    return 1
    else
        cd ./src
        catkin_init_workspace
        cd ..
    fi

    if [ -n `which tree` ]; then
        tree -a
    fi

    if [ -z `which catkin_make` ]; then
    	echo "No such cmd: catkin_make"
	    return 1
    else
        catkin_make
        source ./devel/setup.sh
    fi

    if [ -n `which tree` ]; then
        tree -a
    fi
}

function main()
{
    echo "Are you sure init ROS catkin workspace under current dir?(yes/no)"
    read ans
    case "$ans" in
        yes|Y|y)
            init_catkin_ws
        ;;
        *)
        echo "Do nothings, Bye!"
    esac
}

main

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Oscar   2019-08-20  v0.1       Initial version create
# Reference:
# [创建一个ROS工作空间](https://www.cnblogs.com/huangjianxin/p/6347416.html)
###############################################################################