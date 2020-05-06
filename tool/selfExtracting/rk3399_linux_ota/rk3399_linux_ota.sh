#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Zhou<kevin.zhou@robotemi.com>
# Date    : 2019-09-23
# Version : v1.0
# Abstract: None
# Usages  : None
# History : Please check the end of file.
###############################################################################

SOM_IMG_VER=0
SOM_IMG_NAM=ota.img
SOM_IMG_MD5=0
KERNEAL_VER="$(uname -v)"
VERSION_FIL=~/Desktop/Image_Version
TEMI_PASSWD='Algo!@Robo#$01%10^18'

SCRIPT_PATH=`dirname "$(realpath $0)"`
SCRIPT_NAME=`basename "$(realpath $0)"`
EXEREALPATH=$(realpath $0)

OTA_PACKAGE="rk3399_linux_ota-$(date +%Y%m%d)"
OTA_TMP_DIR='.rk3399_linux_ota'
TMPFILEPATH=/tmp/readout.img
IMG_DEV_NAM=/dev/mmcblk1
IMG_BLK_CNT=180223

function ota_info()
{
    echo 
    echo "   _______________   "
    echo "  |  ___________  |  "
    echo "  | | HEY TEMI  | |  "
    echo "  | |           | |  "
    echo "  | |  make it  | |  "
    echo "  | |   FuNkY   | |  "
    echo "  | |___________| |  "
    echo "  |_______________|  "
    echo "     |         |     "
    echo "     |\       /|     "
    echo "     | ------- |     "
    echo "     |         |     "
    echo "     |         |     "
    echo "    _|__|/ \|__|_    "
    echo "   / ********** \    "
    echo " /  ************  \  "
    echo "---------------------"
    echo 
    echo "Updating SOM Image version: $SOM_IMG_VER"
    echo "1. DDR compatibility"
    echo "2. GPU driver updated"
    echo "3. IPC enabled"
    echo "4. MQUEUE enabled"
    echo "Use 'uname -v' to check your version"
    echo "$KERNEAL_VER"
    echo "--------------------------------------------"
}

function ota_usages()
{
    echo 
    echo "X3388 Linux OTA Usage:"
    echo "./ota.run [-d] [-u [-v version]] [-n [-v version]] [-h]"
    echo "-d deploy the ota package."
    echo "-u update the ota package."
    echo "-n create a new ota package."
    echo "-v the version of ota package."
    echo "-h display the help info."
    echo "for example:"
    echo "create a execable ota: ./ota -n -v 1.9"
    echo "deploy a execable ota: ./ota [-d]"
}

function ota_deploy_curr_package()
{
    echo "Be about to deploy the OTA package..."

    [ ${SOM_IMG_VER} = 0 ] && echo "[Error: No ota image file!]" && ota_usages && return 1

    echo "Read out current image and try comparing md5"
    echo ${TEMI_PASSWD} | sudo -S dd if="$IMG_DEV_NAM" of="$TMPFILEPATH" skip=1 bs=512 count=${IMG_BLK_CNT} conv=sync
    local md5val=`md5sum ${TMPFILEPATH} | cut -d ' ' -f1`

    if [ "${SOM_IMG_MD5}" != "${md5val}" ]; then
        echo "Backup old image to ${TMPFILEPATH}_bk"
        cp ${TMPFILEPATH} ${TMPFILEPATH}_bk
        echo "Start upgrading..."
        local img_realpath="$EXTRACT_DIR/$OTA_TMP_DIR/$SOM_IMG_NAM"
        if [ -z "$EXTRACT_DIR" ] && [ -f "$SOM_IMG_NAM" ]; then
        	img_realpath="$SOM_IMG_NAM"
        fi
        [ ! -f "$img_realpath" ] && echo "[Err: No image file!]" && return 1
        echo ${TEMI_PASSWD} | sudo -S dd if="$img_realpath" of="$IMG_DEV_NAM" seek=1 bs=512 count=${IMG_BLK_CNT} conv=sync
        sync
        echo "Flashed, check upgraded file."
        echo ${TEMI_PASSWD} | sudo -S dd if="$IMG_DEV_NAM" of="$TMPFILEPATH" skip=1 bs=512 count=${IMG_BLK_CNT} conv=sync
        sync
        md5val=`md5sum ${TMPFILEPATH} | cut -d ' ' -f1`
        if [ "${SOM_IMG_MD5}" = "${md5val}" ]; then
            echo "IMAGE read back, MD5SUM check successfully"
            sed -i "s/^Version.*$/Version=${SOM_IMG_VER}/" ${VERSION_FIL}
            sync
            ota_info
            echo "Upgrade successfully, now you need to reboot!!!"
            return 0
        else
            echo "IMAGE read back, MD5SUM check failed, OMGGGG......"
            # No Idea what we should do except run the script again?
            return 2
        fi
    else
        echo "The kernel is already up to date, let's go!"
        return 0
    fi
}

function ota_update_curr_package()
{
    echo "Be about to read the image and update the OTA package..."
    ota_create_new_package $@
}

function ota_create_new_package()
{
    echo "Be about to read the image and create the OTA package..."

    if [ $# -lt 1 ]; then
        echo "Error: Version number must be entered!"
        ota_usages
        return 1
    fi

    if [ ! -d "$OTA_TMP_DIR" ]; then
        mkdir $OTA_TMP_DIR
    elif [ "`ls -A ${OTA_TMP_DIR}`" != "" ]; then
        echo "The folder [$OTA_TMP_DIR] exists and is not empty,"
        echo "Please backup it to another location first, then again."
        return 2
    fi

    echo ${TEMI_PASSWD} | sudo -S dd if="$IMG_DEV_NAM" of="$TMPFILEPATH" skip=1 bs=512 count=${IMG_BLK_CNT} conv=sync
    local md5val=`md5sum ${TMPFILEPATH} | cut -d ' ' -f1`
    cp ${TMPFILEPATH} ${OTA_TMP_DIR}/ota-${md5val}.img
    sed -i "s/^SOM_IMG_NAM=.*$/SOM_IMG_NAM=ota-${md5val}.img/" ${EXEREALPATH}
    sed -i "s/^SOM_IMG_VER=.*$/SOM_IMG_VER=${1}/"              ${EXEREALPATH}
    sed -i "s/^SOM_IMG_MD5=.*$/SOM_IMG_MD5=${md5val}/"         ${EXEREALPATH}
    sed -i "s/^KERNEAL_VER=.*$/KERNEAL_VER='$(uname -v)'/"     ${EXEREALPATH}
    cp ${EXEREALPATH} ${OTA_TMP_DIR}/${SCRIPT_NAME}
    ${MAKESELF_SH} makeself -s ${OTA_PACKAGE} -p ${OTA_TMP_DIR} -e ${OTA_TMP_DIR}/${SCRIPT_NAME}
    md5val=`md5sum ${OTA_PACKAGE} | cut -d ' ' -f1`
    mv ${OTA_PACKAGE} rk3399_linux_ota-v${1}-${md5val}.run
    rm -rf $OTA_TMP_DIR
    
    echo "New OTA package create successfully!"
    echo "The execable ota named [rk3399_linux_ota-v${1}-${md5val}.run]."
}

function ota_main()
{
    local ota_ver
    local flag

    while getopts ":dunv:h" opt > /dev/null; do
        case "$opt" in
            d) flag=0 ; break ;;
            u) flag=1 ;;
            n) flag=2 ;;
            v) ota_ver="$OPTARG" ;;
            h|?)
                ota_usages
                return 0
                ;;
        esac
    done

    if [ -z ${flag} ] || [ ${flag} = 0 ]; then
        ota_deploy_curr_package
    elif [ -n "$ota_ver" ]; then
        case $flag in
            1) ota_update_curr_package $ota_ver ;;
            2) ota_create_new_package  $ota_ver ;;
        esac
    else
        echo "*** [Warning: Version number must be entered!] ***"
        ota_usages
    fi
}

ota_main $@

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Zhou   2019-09-23   v1.0       Initial version create
###############################################################################