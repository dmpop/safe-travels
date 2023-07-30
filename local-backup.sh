#!/bin/bash

# Author: Dmitri Popov, dmpop@cameracode.coffee
# Source code: https://github.com/dmpop/ish-scripts

# Specify ntfy_topic to enable ntfy.sh notifications
ntfy_server="ntfy.sh"
ntfy_topic=""

if [ -z "$1" ]; then
    dialog --erase-on-exit --backtitle "Error" --msgbox "Specify an identifier, e.g.:\n\n$0 CARD1" 9 32
    exit 1
fi

if [ ! -x "$(command -v rsync)" ] || [ ! -x "$(command -v dialog)" ] || [ ! -x "$(command -v curl)" ]; then
    apk update
    apk upgrade
    apk add rsync dialog curl
fi

mkdir -p "$1"
dialog --erase-on-exit --backtitle "Info" --msgbox "When prompted, choose the SOURCE folder." 7 30
mount -t ios . "$1"
mkdir -p backup
dialog --erase-on-exit --backtitle "Info" --msgbox "When prompted, choose the DESTINATION folder." 7 30
mount -t ios . backup

rsync -av --info=progress2 --delete "$1" "backup/"
umount "$1"
umount backup

if [ ! -z "$ntfy_topic" ]; then
    curl \
        -d "Backup completed. Have a nice day!" \
        -H "Title: Message from iSH" \
        "$ntfy_server/$ntfy_topic" >/dev/null 2>&1
fi
