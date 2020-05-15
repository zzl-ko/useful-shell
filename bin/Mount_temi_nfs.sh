#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Oscar<zrzxlfe@sina.com>
# Date    : 2019-09-27
# Version : v0.1
# Abstract: mount temi's nfs
# Usages  : None
# History : Please check the end of file.
###############################################################################

NFS_SER_ADDR='172.16.6.6:/home/nfs/tShare'
NFS_MNT_PATH='/home/kevin/TemiNfs'

if [ "$1" = "-u" ]; then
    sudo umount ${NFS_MNT_PATH}
else
    sudo mount.nfs -o nosuid,noexec,nodev,rw,bg,soft,retry=5,rsize=32768,wsize=32768 ${NFS_SER_ADDR} ${NFS_MNT_PATH}
fi

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Oscar   2019-09-27  v0.1       Initial version create
#------------------------------------------------------------------------------
# refer: http://note.youdao.com/noteshare?id=cdd6a55a429aee4b7b127c9f3c6f9eed
###############################################################################
