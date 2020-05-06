#!/usr/bin/env bash
###############################################################################
# Author  : Kevin Oscar<zrzxlfe@sina.com>
# Date    : 2020-04-28
# Version : v0.1
# Abstract: Simple audio recorder for linux
# Usages  :
# History : Please check the end of file.
###############################################################################

FILE="$1"

## Get file name
if [ -z "$FILE" ]; then
    FILE=`zenity --file-selection --save --title="Choose file to save" --confirm-overwrite`
fi

if [ -z "$FILE" ]; then exit 0; fi

FILENAME=$(basename "$FILE")
FILEEXT="${FILENAME##*.}"

case $FILEEXT in
    mp3 | MP3)
        COMMAND="arecord -vv -f dat -t raw | lame -r - ${FILE}"
        ;;
    ogg | OGG)
        COMMAND="arecord -f dat -t raw | oggenc - -r -o ${FILE}"
        ;;
    wav | WAV)
        COMMAND="arecord -vv -f dat ${FILE}"
        ;;
    *)
        zenity --error --text="File extension not recognised."
        exit 1
esac

xterm -T "Recording to ${FILENAME}" -bg "#990000" -geometry 80x10 -e "trap '' INT; exec ${COMMAND}"

###############################################################################
# Author        Date        Version    Abstract
#------------------------------------------------------------------------------
# Kevin Oscar   2020-04-28  v0.1       Initial version create
#------------------------------------------------------------------------------
# Ref: https://github.com/eev2/audio-record/blob/master/audio-record
###############################################################################