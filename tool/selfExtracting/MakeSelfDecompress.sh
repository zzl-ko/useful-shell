#!/bin/bash
# 注： 笔者在Ubuntu16.04下测试失败
CURRENT_DIR=$(realpath $(pwd))
EXTRACT_DIR=$CURRENT_DIR/.extract
ENCOMPRESS='tar -zcvf'
UNCOMPRESS='tar -zxvf'
SELF_SCRIPT=$(basename "$(realpath $0)")
EXEC_SCRIPT=setup.sh

function self_decompress_usage(){
    echo "Describe usage of your setup.sh ..."
}

function self_decompress_setup(){
    # https://blog.csdn.net/zhedanxc/article/details/78233393
    # 计算当前文件的总行数，以便可以把当前脚本的内容能和升级包的内容区别
    local total_lines=$(cat $0 | wc -l)
 　  # 因为 wc -l 命令只能统计文件中的换行符的数目，由于当前脚本要和压缩包拼接到一起，因此最后一样末尾是不能有换行符的，所以总行数需要+1
    ((total_lines++))
    # 利用 __SETUP_END__ 来表示脚本结束，也可以使用其他的标记，这里要计算出当前脚本的行数，用于计算拼接后的升级包内容的起始位置
    local code_lines=$(sed '/^# __SETUP_END__$/q' $0 | wc -l)
    local pkg_lines=$((total_lines - code_lines))
    # 用于存放解压缩后的升级包
    rm -rf $EXTRACT_DIR && mkdir $EXTRACT_DIR
    # 用于输出自解压脚本文件
    tail -n $code_lines $0 > make_self_decompress.sh
    # 把升级包的内容取出用tar命令解压，这里视压缩包的类型而定
    tail -n $pkg_lines $0 | tar -zxvf -C $EXTRACT_DIR
    # 此时包已经解压成功，之后便是执行包中真正的脚本或可执行程序
    if [ -f "$EXTRACT_DIR/$EXEC_SCRIPT" ]; then
        chmod +x $EXTRACT_DIR/$EXEC_SCRIPT
        $EXTRACT_DIR/$EXEC_SCRIPT $@
    elif [ $# -ge 1 ]; then
        chmod +x $EXTRACT_DIR/$1
        shift
        $EXTRACT_DIR/$1 $@
    else
        echo "There is no other actions, will go to exit!"
    fi

    return $?
}

function self_decompress_make(){
    local script
    local package

    while getopts ":p:s:" opt > /dev/null; do
        case "$opt" in
            p)
                package="$OPTARG"
                ;;
            s)
                script="$OPTARG"
                ;;
            ?)
                echo "Unknown argument!" >&2
                echo "self_decompress_make usage:"
                echo "1. tar -zcvf package.tar.gz setup.sh package"
                echo "2. cat self_decompress_setup.sh package.tar.gz > package.sh"
                echo "3. chmod +x package.sh"
                # setup.sh 代表真正的执行脚本，arg1、arg2等为 setup.sh 支持的参数
                echo "4. ./package.sh setup.sh arg1 arg2 ..."
                exit 1
                ;;
        esac
    done

    ${ENCOMPRESS} package.tar.gz "$package" "$script"
    cp "$SELF_SCRIPT" ."$SELF_SCRIPT"
    if [ -f "$script" ] && [ "setup.sh" != "$script" ]; then
        sed "s/^EXEC_SCRIPT=setup.sh$/EXEC_SCRIPT=${script}/" ."$SELF_SCRIPT"
    fi
    cat ."$SELF_SCRIPT" package.tar.gz > package.sh
    chmod +x package.sh
    rm -f ."$SELF_SCRIPT"
}

function main(){
    if [ "$1" = "makeself" ]; then
        shift
        self_decompress_make $@
    else
        self_decompress_setup $@
    fi
}

main $@
# 一定要退出脚本，因为后面的内容就是升级包的内容了
exit $?
# do not append newline or anything after __SETUP_END__
# __SETUP_END__