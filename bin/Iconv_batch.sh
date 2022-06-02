#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Oscar<zrzxlfe@sina.com>
# Date    : 2019-09-27
# Version : v0.1
# Abstract: Batch conversion of file encoding
# Usages  : None
# History : Please check the end of file.
###############################################################################

function method_1() {
if [ "$#" != "2" ]; then
  echo "Usage: `basename $0` dir filter"
  exit
fi

dir=$1
filter=$2

echo $1

for file in `find $dir -name "$2"`; do
  echo "$file"
  iconv -f gbk -t utf8 -o $file $file
done
}

function mesond_2() {
convertCodeFilePath=$1 
fromCode=$2 
toCode=$3 
  
for i in {1..1} 
do
  [ -f $convertCodeFilePath ] 
  if [ $? -eq 0 ] 
  then
    iconv -f $fromCode -t $toCode -c -o $convertCodeFilePath $convertCodeFilePath 
    if [ $? -ne 0 ] 
    then
      echo $convertCodeFilePath "=>" convert code failed.      
    else
      echo $convertCodeFilePath "=>" convert code success. 
    fi
    break; 
  fi
    
  [ -d $convertCodeFilePath ] 
  if [ $? -ne 0 ] 
  then
    break; 
  fi
      
  dir=`ls $convertCodeFilePath | sort -d` 
  
  for fileName in $dir
  do
    fileFullPatch=$convertCodeFilePath/$fileName 
      
    fileType=`echo $fileName |awk -F. '{print $2}'` 
      
    [ -d $fileName ] 
    if [ $? -eq 0 ] 
    then
      continue
    fi
      
    if [ $fileType != 'sh' ] && [ $fileType != 'py' ] && [ $fileType != 'xml' ] && [ $fileType != 'properties' ] \
    && [ $fileType != 'q' ] && [ $fileType != 'hql' ] && [ $fileType != 'txt' ] 
    then
      continue
    fi
      
    iconv -f $fromCode -t $toCode -c -o $fileFullPatch $fileFullPatch 
    if [ $? -ne 0 ] 
    then
      echo $fileName "=>" convert code failed. 
      continue
    else
      echo $fileName "=>" convert code success. 
    fi    
  done
done
}

mesond_2 $@

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Oscar   2021-09-23  v0.1       Initial version create
#------------------------------------------------------------------------------
# refer: https://www.jb51.net/article/53211.htm
###############################################################################