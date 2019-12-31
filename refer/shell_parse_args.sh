#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Zhou <zzl.ko@outlook.com>
# Date    : 2019-08-27
# Version : v1.0
# Abstract: test parse arguments under shell via getopt/getopts
# Usages  : None
# History : Please check the end of file.
###############################################################################

function use_getopts_parse_args()
{
    echo 初始的 OPTIND: $OPTIND

    while getopts ":a:B:cd:f" opt #第一个冒号表示忽略错误；选项后面的冒号表示该选项需要参数
    do
        case $opt in
            a)
                echo "a's arg: $OPTARG" #参数存在$OPTARG中
                ;;
            B)
                echo "B's arg: $OPTARG"
                ;;
            c)
                echo "c no need arg"
                ;;
            d)
                echo "d's arg: $OPTARG"
                ;;
            f)
                echo "f no need arg"
                ;;
            ?)  #当有不认识的选项时opt为?
                echo 
                echo "Unkonw argument"
                echo "Usage: use_getopts_parse_args [OPTINON]"
                echo "[OPTION]: [-a arg] [-B arg] [-c] [-d arg] [-f]"
                echo 
                #exit 1
                ;;
        esac
    done

    echo 处理完参数后的 OPTIND: $OPTIND
    echo 移除已处理参数个数: $((OPTIND-1))
    shift $((OPTIND-1))
    echo 参数索引位置: $OPTIND
    echo 准备处理余下的参数:
    echo "Other Params: $(if [ -z $@ ];then echo None; else echo $@; fi)"

    unset OPTIND

# for example
###############################################################################
# 命令行输入: ./Teamplate -f -a 12 -B 34 -cd 56 -g
# 使用如下方式调用以获取命令行参数: use_getopts_parse_args "$@"
# 结果输出：
# 初始的 OPTIND: 1
# f no need arg
# a's arg: 12
# B's arg: 34
# c no need arg
# d's arg: 56
# ./Template.sh: illegal option -- g
#
# Unkonw argument
# Usage: use_getopts_parse_args [OPTINON]
# [OPTION]: [-a arg] [-B arg] [-c] [-d arg] [-f]
#
# 处理完参数后的 OPTIND: 9
# 移除已处理参数个数: 8
# 参数索引位置: 9
# 准备处理余下的参数：
# Other Params: None

# 此外也可直接传参调用本函数: use_getopts_parse_args -f -a 12 -cd 56 -g  -B 34
###############################################################################
# use_getopts_parse_args "$@"
# echo "=== split line ==="
# use_getopts_parse_args -f -a 12 -B 34 -cd 56 -g
}

function use_getopts_parse_long_args()
{
    optspec=":hv-:"
    while getopts "$optspec" optchar; do
        case "${optchar}" in
            -)
                case "${OPTARG}" in
                    loglevel)
                        val="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
                        echo "Parsing option1: '--${OPTARG}', value: '${val}'" >&2;
                        ;;
                    loglevel=*)
                        val=${OPTARG#*=}
                        opt=${OPTARG%=$val}
                        echo "Parsing option2: '--${opt}', value: '${val}'" >&2
                        ;;
                    *)
                        if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                            echo "Unknown option --${OPTARG}" >&2
                        fi
                        ;;
                esac;;
            h)
                echo "usage: $0 [-v] [--loglevel[=]<value>]" >&2
                #exit 2
                ;;
            v)
                echo "Parsing option: '-${optchar}'" >&2
                ;;
            *)
                if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                    echo "Non-option argument: '-${OPTARG}'" >&2
                fi
                ;;
            ?)
                echo "Unknown argument!"
                ;;
        esac
    done
}

function use_getopt_parse_args()
{
    # 定义选项: -o 表示短选项 -a 表示支持长选项的简单模式(以 - 开头) -l 表示长选项 
    # a 后没有冒号，表示没有参数
    # b 后跟一个冒号，表示有一个必要参数
    # c 后跟两个冒号，表示有一个可选参数(可选参数必须紧贴选项)
    # -n 出错时的信息
    # -- 也是一个选项，比如要创建一个名字为 -f 的目录，会使用 mkdir -- -f , 在这里用做表示最后一个选项(用以判定 while 的结束)
    # $@ 从命令行取出参数列表(不能用用 $* 代替，因为 $* 将所有的参数解释成一个字符串，而 $@ 是一个参数数组)

    TEMP=`getopt -o ab:c:: -a -l apple,banana:,cherry:: -n "test.sh" -- "$@"`
     
    # 判定 getopt 的执行时候有错，错误信息输出到 STDERR
    if [ $? != 0 ]
    then
	    echo "Terminating....." >&2
	    exit 1
    fi

    # 重新排列参数的顺序
    # 使用 eval 是为了防止参数中有shell命令，被错误的扩展。
    eval set -- "$TEMP"
     
    # 处理具体的选项
    while true
    do
        case "$1" in
            -a | --apple | -apple)
                echo "option a, no argument"
                shift
                ;;
            -b | --banana | -banana)
                echo "option b, argument $2"
                shift 2
                ;;
            -c | --cherry | -cherry)
                case "$2" in
                    "") # 选项 c 带一个可选参数，如果没有指定就为空
                        echo "option c, no argument"
                        shift 2
                        ;;
                    *)
                        echo "option c, argument $2"
                        shift 2
                esac
                ;;
            --)
                shift
                break
                ;;
            *) 
                echo "Internal error!"
                exit 1
                ;;
        esac
    done
     
    # 显示除选项外的参数(不包含选项的参数都会排到最后)
    # arg 是 getopt 内置的变量, 里面的值，就是处理过之后的 $@(命令行传入的参数)
    for arg do
       echo '--> '"$arg" ;
    done
}

echo "***test function use_getopts_parse_args:"
use_getopts_parse_args "$@"
echo

echo "***test function use_getopts_parse_long_args:"
use_getopts_parse_long_args -v --loglevel 9 -h
echo

echo "***test function use_getopt_parse_args:"
use_getopt_parse_args -a -banana 12 --cherry=34

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Zhou   2019-08-09   v1.0       Initial version create
#==============================================================================
# refer:
# [【shell笔记>参数解析】使用getopts解析长格式输入参数](https://www.jianshu.com/p/afea5d441849)
# [linux shell命令行选项与参数用法详解--getopts、getopt](https://www.jianshu.com/p/6393259f0a13)
# [getopt/getopts：Bash中命令行选项/参数处理](https://blog.csdn.net/u011641885/article/details/47429273)
###############################################################################

# getopt 与 getopts 的区别
#     getopt命令并不是bash的内建命令，它是由util-linux包提供的外部命令
#     getopts 是 shell 内建命令， getopt 是一个独立外部工具
#     getopts 使用语法简单，getopt 使用语法复杂
#     getopts 不支持长参数（长选项，如 --option）， getopt 支持
#     getopts 不会重排所有参数的顺序，getopt会重排参数顺序 (getopts 的 shell 内置 OPTARG 这个变量，getopts 通过修改这个变量依次获取参数，
#             而 getopt 必须使用 set 来重新设定位置参数，然后在 getopt 中使用 shift 来依次获取参数)
#     如果某个参数中含有空格，那么这个参数就变成了多个参数。因此，基本上，如果参数中可能含有空格，那么必须用getopts(新版本的 getopt 也可以使用空格的参数，只是传参时，需要用 双引号 包起来)。
#
# getopt 命令选项说明：
#     getopt 命令的选项说明：
#     -a 使getopt长选项支持"-"符号打头，必须与-l同时使用
#     -l 后面接getopt支持长选项列表
#     -n program如果getopt处理参数返回错误，会指出是谁处理的这个错误，这个在调用多个脚本时，很有用
#     -o 后面接短参数选项，这种用法与getopts类似，
#     -u 不给参数列表加引号，默认是加引号的（不使用-u选项），例如在加不引号的时候 --longopt "select * from db1.table1" $2只会取到select ，而不是完整的SQL语句。
#
#     选项的使用定义规则类似 getopts ：
#     例如
#     ab:c::
#     意思是：
#     a 后没有冒号，表示没有可选参数
#     b 后跟一个冒号，表示有一个必要的参数
#     c 后跟两个冒号，表示有一个可选的参数（参数必须紧挨着选项）
#     长选项的定义相同，但用逗号分割。
