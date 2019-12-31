#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Zhou <zzl.ko@outlook.com>
# Date    : 2019-07-21
# Version : v1.0
# Abstract: svn -> git
# Usages  : None
# History : Please check the end of file.
###############################################################################

svn_url=https://192.168.1.129/svn/PH500/Repeater
svn_rev=svn.rev

echo "svn url:" $svn_url

function get_svn_reversion()
{
    sREV=BASE
    eREV=HEAD
    
    if [[ -n "$1" && -n "$2" ]]; then
        if [ $1 -lt $2 ]; then
            sREV=$1
            eREV=$2
        else
            sREV=$2
            eREV=$1
        fi
    elif [ -n "$1" ]; then
        eREV=$1
    fi
    
    svn log -r $eREV:$sREV | grep -a -v '(no author)' | grep -a -o '^r[0-9]\+' | grep -a -o '[0-9]\+' > $svn_rev
    
    # start reversion
    # if [ -n $1 ]; then
        # sline=$1
        # sed '/^"$sline"$/,$d' $svn_rev
    # fi
    
    # end reversion
    # if [ -n $2 ]; then
        # eline=$2
        # sed -i '/1,/$eline/d' $svn_rev
    # fi
}

function svn_checkout_reversion()
{
    if [ -n $1 ]; then
        svn co -r $1
    fi
}

function svn2git_reversion()
{
    tmp_log=tmp.log
    svn_log=svn.log
    sed -i '$d' $svn_rev
    
    for n in `tac $svn_rev`
    do
        svn update -r $n
        svn log -l 1 -r $n > $tmp_log
        sed -i -e '/^$/d' -e '/^-\+/d' $tmp_log
        sed -n '1p' $tmp_log >> $tmp_log
        sed -i '1d' $tmp_log
        ./busybox.exe iconv -f GBK -t UTF-8 -o $svn_log $tmp_log
        git add -A
        git commit -F $svn_log
    done
    
    rm -f $tmp_log $svn_log
}

function test()
{
    svn update -r 17385
    svn log -l 1 -r 17385 > tmp.log
    sed -i -e '/^$/d' -e '/^-\+/d' tmp.log
    # 为了便于git下查看，将svn中关于日期，修改人等信息移到最后
    sed -n '1p' tmp.log >> tmp.log # 将第一行追加到文件最后
    sed -i '1d' tmp.log            # 再删除原有的“第一行”
    # 以上生成的 tmp.log 由于编码问题，当有中文时git commit log会乱码
    # shell 下可直接使用 iconv 来转换文件编码, 
    # 但Windows中自带的 iconv.exe 版本太低，无法使用，故借助 busybox
    # iconv -f GBK -t UTF-8 -o temp.log tmp.log
    ./busybox.exe iconv -f GBK -t UTF-8 -o temp.log tmp.log
    git add -A
    git commit -F temp.log
    rm -f tmp.log temp.log
}

function main()
{
    get_svn_reversion
    # cat $svn_rev
    svn2git_reversion
    rm $svn_rev
}

# test
main

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Zhou   2019-07-21   v1.0       Initial version create
#==============================================================================