#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Zhou<kevin.zhou@robotemi.com>
# Date    : 2019-09-23
# Version : v1.0
# Abstract: None
# Usages  : None
# History : Please check the end of file.
###############################################################################

BAK_BLK_CNT=2
BAK_BLK_SKP=1
SOM_IMG_VER=0
SOM_IMG_NAM=ota.img
SOM_IMG_MD5=0
TYPE_OF_IMG=none
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
IMG_BLK_SKP=1

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
    echo "X3399 Linux OTA Version $SOM_IMG_VER Usage:"
    echo "./ota.run [-d] [-N [-v version]] [-n [-v version] [-lLuUtTmMrRkKB] [-h]"
    echo "-d deploy the ota package."
    echo "-n create a new ota package."
    echo "-N update the ota package."
    echo "-v the version of ota package."
    echo "-l read from loader to boot"
    echo "-L only read loader"
    echo "-u read from uboot to boot"
    echo "-U only read uboot"
    echo "-t read from trust to boot"
    echo "-T only read trust"
    echo "-m read from misc to boot"
    echo "-M only read misc"
    echo "-r read from resource(dtb) to boot"
    echo "-R only read resource(dtb)"
    echo "-k read from kernel to boot"
    echo "-K only read kernel"
    echo "-B only read boot"
    echo "-h display the help info."
    echo "for example:"
    echo "create a execable ota: ./ota -n -v 1.9 [-k]"
    echo "deploy a execable ota: ./ota [-d]"
    echo 
    echo "Firmware store map:"
    echo "('0x00002000+0x00002000+0x00002000+0x00002000+0x00008000+0x0000C000+0x00010000 - 1 ', opensource.rock-chips.com/wiki_Partitions)"
    echo "('reserved   uboot      trust      misc       resource   kernel     boot        MBR', refer parameter.txt)"
    echo 
    echo "TYPE_OF_IMG: $TYPE_OF_IMG"
    echo "BAK_BLK_CNT: $BAK_BLK_CNT"
    echo "BAK_BLK_SKP: $BAK_BLK_SKP"
    echo "IMG_BLK_CNT: $IMG_BLK_CNT"
    echo "IMG_BLK_SKP: $IMG_BLK_SKP"
    echo "KERNEAL_VER: $KERNEAL_VER"
}

function ota_cmdline_parser()
{
    local flag=0

    while getopts ":hdnNv:lLuUtTmMrRkKB" opt > /dev/null; do
        case "$opt" in
            d) flag=1 ;;
            n) flag=2 ;;
            N) flag=3 ;;
            v) SOM_IMG_VER="$OPTARG" ;;
            l) IMG_BLK_SKP=64     ; IMG_BLK_CNT=7104   ; TYPE_OF_IMG="-l (from loader)"   ;;
            L) IMG_BLK_SKP=64     ; IMG_BLK_CNT=8191   ; TYPE_OF_IMG="-L (only loader)"   ;;
            u) IMG_BLK_SKP=8192   ; IMG_BLK_CNT=172032 ; TYPE_OF_IMG="-u (from uboot)"    ;;
            U) IMG_BLK_SKP=8192   ; IMG_BLK_CNT=8192   ; TYPE_OF_IMG="-U (only uboot)"    ;;
            t) IMG_BLK_SKP=16384  ; IMG_BLK_CNT=163840 ; TYPE_OF_IMG="-t (from trust)"    ;;
            T) IMG_BLK_SKP=16384  ; IMG_BLK_CNT=8192   ; TYPE_OF_IMG="-T (only trust)"    ;;
            m) IMG_BLK_SKP=24576  ; IMG_BLK_CNT=155648 ; TYPE_OF_IMG="-m (from misc)"     ;;
            M) IMG_BLK_SKP=24576  ; IMG_BLK_CNT=8192   ; TYPE_OF_IMG="-M (only misc)"     ;;
            r) IMG_BLK_SKP=32768  ; IMG_BLK_CNT=147456 ; TYPE_OF_IMG="-r (from resource)" ;;
            R) IMG_BLK_SKP=32768  ; IMG_BLK_CNT=32768  ; TYPE_OF_IMG="-R (only resource)" ;;
            k) IMG_BLK_SKP=65536  ; IMG_BLK_CNT=114688 ; TYPE_OF_IMG="-k (from kernel)"   ;;
            K) IMG_BLK_SKP=65536  ; IMG_BLK_CNT=49152  ; TYPE_OF_IMG="-K (only kernel)"   ;;
            B) IMG_BLK_SKP=114688 ; IMG_BLK_CNT=65536  ; TYPE_OF_IMG="-B (only boot)"     ;;
            h|?) ota_usages && exit 1 ;;
        esac
    done

    if [[ ${flag} -eq 0 ]] && [[ ${SOM_IMG_VER} != 0 ]]; then
    	IMG_BLK_SKP=${BAK_BLK_SKP}
    	IMG_BLK_CNT=${BAK_BLK_CNT}
    fi
    echo "IMG_BLK_SKP: $IMG_BLK_SKP, IMG_BLK_CNT: $IMG_BLK_CNT"

    return $flag # max return 255
}

function ota_deploy_curr_package()
{
    echo "Be about to deploy the OTA package..."

    [[ ${SOM_IMG_VER} = 0 ]] && echo "[Error: No ota image file!]" && ota_usages && return 1
    [[ ${IMG_BLK_SKP} -ne ${BAK_BLK_SKP} ]] && echo "[Error: fireware version incompatibility!]" && ota_usages && return 1
    [[ ${IMG_BLK_CNT} -ne ${BAK_BLK_CNT} ]] && echo "[Error: fireware version incompatibility!]" && ota_usages && return 1

    local img_realpath="$EXTRACT_DIR/$OTA_TMP_DIR/$SOM_IMG_NAM"
    if [ -z "$EXTRACT_DIR" ] && [ -f "$SOM_IMG_NAM" ]; then
        img_realpath="$SOM_IMG_NAM"
    fi
    [ ! -f "$img_realpath" ] && echo "[Err: No image file{$tmp_realpath}!]" && return 1

    echo "Read out current image and try comparing md5"
    echo ${TEMI_PASSWD} | sudo -S dd if="$IMG_DEV_NAM" of="$TMPFILEPATH" skip=${IMG_BLK_SKP} bs=512 count=${IMG_BLK_CNT} conv=sync
    local md5val=`md5sum ${TMPFILEPATH} | cut -d ' ' -f1`

    if [ "${SOM_IMG_MD5}" != "${md5val}" ]; then
        echo "Backup old image to ${TMPFILEPATH}_bk"
        cp ${TMPFILEPATH} ${TMPFILEPATH}_bk
        echo "Start upgrading..."
        echo ${TEMI_PASSWD} | sudo -S dd if="$img_realpath" of="$IMG_DEV_NAM" seek=${IMG_BLK_SKP} bs=512 count=${IMG_BLK_CNT} conv=sync
        sync
        echo "Flashed, check upgraded file."
        echo ${TEMI_PASSWD} | sudo -S dd if="$IMG_DEV_NAM" of="$TMPFILEPATH" skip=${IMG_BLK_SKP} bs=512 count=${IMG_BLK_CNT} conv=sync
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

    echo ${TEMI_PASSWD} | sudo -S dd if="$IMG_DEV_NAM" of="$TMPFILEPATH" skip=${IMG_BLK_SKP} bs=512 count=${IMG_BLK_CNT} conv=sync
    local md5val=`md5sum ${TMPFILEPATH} | cut -d ' ' -f1`
    local imgsiz=`du -b "$TMPFILEPATH" | awk '{print $1}'`
    if [[ ${IMG_BLK_CNT} -ne $((imgsiz/512)) ]]; then
        echo "[Error: read image size! should ${IMG_BLK_CNT} but $((imgsiz/512))"
    else
        cp ${TMPFILEPATH} ${OTA_TMP_DIR}/${md5val}.img
    fi
    sed -i "s/^BAK_BLK_CNT=.*$/BAK_BLK_CNT=${IMG_BLK_CNT}/"    ${EXEREALPATH}
    sed -i "s/^BAK_BLK_SKP=.*$/BAK_BLK_SKP=${IMG_BLK_SKP}/"    ${EXEREALPATH}
    sed -i "s/^SOM_IMG_NAM=.*$/SOM_IMG_NAM=${md5val}.img/"     ${EXEREALPATH}
    sed -i "s/^SOM_IMG_VER=.*$/SOM_IMG_VER=${1}/"              ${EXEREALPATH}
    sed -i "s/^SOM_IMG_MD5=.*$/SOM_IMG_MD5=${md5val}/"         ${EXEREALPATH}
    sed -i "s/^TYPE_OF_IMG=.*$/TYPE_OF_IMG='${TYPE_OF_IMG}'/"  ${EXEREALPATH}
    sed -i "s/^KERNEAL_VER=.*$/KERNEAL_VER='$(uname -v)'/"     ${EXEREALPATH}
    cp ${EXEREALPATH} ${OTA_TMP_DIR}/${SCRIPT_NAME}
    ${MAKESELF_SH} makeself -s ${OTA_PACKAGE} -p ${OTA_TMP_DIR} -e ${OTA_TMP_DIR}/${SCRIPT_NAME}
    md5val=`md5sum ${OTA_PACKAGE} | cut -d ' ' -f1`
    package_dist_name=rk3399_linux_ota-v${1}-${md5val}.run
    mv ${OTA_PACKAGE} ${package_dist_name}
    rm -rf $OTA_TMP_DIR
    
    echo "New OTA package create successfully!"
    echo "The execable ota named [${package_dist_name}]."
}

function ota_main()
{
    ota_cmdline_parser $@

    local retv=$?

    if   [[ $retv -eq 0 ]] || [[ $retv -eq 1 ]]; then
        ota_deploy_curr_package
    elif [[ ${SOM_IMG_VER} != 0 ]]; then
        case $retv in
            2) ota_create_new_package  $SOM_IMG_VER ;;
            3) ota_update_curr_package $SOM_IMG_VER ;;
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
# Kevin Zhou   2020-04-30   v1.1       New feture to backup some compoment
###############################################################################