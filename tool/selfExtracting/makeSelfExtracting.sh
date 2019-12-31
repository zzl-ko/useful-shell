#!/bin/bash
###############################################################################
# Author  : Kevin Zhou <zzl.ko@outlook.com>
# Date    : 2019-09-03
# Version : v1.0
# Abstract: make the self-extracting package
# Usages  : None
# History : Please check the end of file.
###############################################################################

PACKAGE_SIZ=0
EXEC_SCRIPT=setup.sh
export EXTRACT_DIR=/tmp/.extract #$(realpath "$(pwd)")/.extract
export MAKESELF_SH=${EXTRACT_DIR}/.makeSelfExtracting.sh
EXEFILE_SEF=$(basename "$(realpath $0)")
TMP_PACKAGE=.pack-$(date +%s)
ENCOMPRESS='tar -jcf'
UNCOMPRESS='tar -jxv -C'

function self_extracting_setup(){
    # refer: https://blog.csdn.net/saintdsc/article/details/47340165
    [ ${PACKAGE_SIZ} = 0 ] && echo "[Err: No self-extracting package!]" && self_extracting_make -h && return 1
    # Create floder for store files that extracting from self-extracting package
    rm -rf $EXTRACT_DIR && mkdir $EXTRACT_DIR
    # Output the script content in the header of the self-extracting package
    local head_lines=$(sed '/^# __SETUP_END_AND_ARCHIVE_BELOW__$/q' $0 | wc -l)
    head -n ${head_lines} $0 > ${MAKESELF_SH} && chmod +x ${MAKESELF_SH}
    sed -i "s/^PACKAGE_SIZ=.*$/PACKAGE_SIZ=0/" ${MAKESELF_SH}
    sed -i "s|^EXEC_SCRIPT=.*$|EXEC_SCRIPT=setup.sh|" ${MAKESELF_SH}
    # Start extracting the self-extracting package to self-extracting the specified floder
    tail -c ${PACKAGE_SIZ} $0 | ${UNCOMPRESS} ${EXTRACT_DIR}
    [ $? -ne 0 ] && echo "[Err: Extracting failed!]" && rm -rf $EXTRACT_DIR && return 2
    echo "*** The package has been unpacked successfully ***"
    # Start perform the actions practiced in the self-extracting package
    if [ -f "$EXTRACT_DIR/$EXEC_SCRIPT" ]; then
        chmod +x $EXTRACT_DIR/$EXEC_SCRIPT
        $EXTRACT_DIR/$EXEC_SCRIPT $@
    elif [ $# -ge 1 ] && [ -f "$1" ]; then
        chmod +x $EXTRACT_DIR/$1
        shift
        $EXTRACT_DIR/$1 $@
    else
        echo "*** There is no other actions, so will return! ***"
    fi
    
    return $?
}

function self_extracting_make(){
    local dstfile
    local package
    local exefile
    while getopts ":s:p:e:" opt > /dev/null; do
        case "$opt" in
            s) dstfile="$OPTARG" ;;
            p) package="$OPTARG" ;;
            e) exefile="$OPTARG" ;;
            h|?)
                echo "Usage: ./makeSelfExtracting.sh makeself [-s dstfile] [-p package] [-e exefile]"
                exit 1
                ;;
        esac
    done

    if [ ! -f "$package" ] && [ ! -d "$package" ] && [ ! -f "$exefile" ]; then
        echo "No such file or directory" && exit 2
    elif [ ! -f "$package" ] && [ ! -d "$package" ]; then
        unset package
    elif [ ! -f "$exefile" ]; then
        unset exefile
    fi
    ${ENCOMPRESS} ${TMP_PACKAGE} ${package} ${exefile}
    cp "$(realpath $0)" ."$EXEFILE_SEF"
    PACKAGE_SIZ=`wc -c ${TMP_PACKAGE} | awk '{print $1}'`
    if [ ${PACKAGE_SIZ} -gt 0 ]; then
        sed -i "s/^PACKAGE_SIZ=0$/PACKAGE_SIZ=${PACKAGE_SIZ}/" ."$EXEFILE_SEF"
    fi
    if [ -f "$exefile" ] && [ "setup.sh" != "$exefile" ]; then
        # "|" is used as the delimiter here to avoid duplication with "/" in the path
        sed -i "s|^EXEC_SCRIPT=setup.sh$|EXEC_SCRIPT=${exefile}|" ."$EXEFILE_SEF"
    fi
    [ -n "$dstfile" ] || dstfile=SelfExtractingPackage.run
    cat ."$EXEFILE_SEF" > ${dstfile}
    cat ${TMP_PACKAGE} >> ${dstfile}
    chmod +x ${dstfile}
    rm -f "$TMP_PACKAGE" ."$EXEFILE_SEF"
    echo "*** The self-extracting package has been created successfully ***"
}

function main(){
    if [ "$1" = "makeself" ]; then
        shift
        self_extracting_make $@
    else
        self_extracting_setup $@
    fi
}

main $@
# Must exit the script because the package contents follow
exit $?
###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Zhou   2019-09-03   v1.0       Initial version create
###############################################################################
# __SETUP_END_AND_ARCHIVE_BELOW__
