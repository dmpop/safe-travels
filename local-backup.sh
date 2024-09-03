#!/bin/bash

# Author: Dmitri Popov, dmpop@cameracode.coffee
# Source code: https://github.com/dmpop/safe-travels

# Specify ntfy_topic to enable ntfy.sh notifications
ntfy_server="ntfy.sh"
ntfy_topic=""

# The name of a directory on the storage card. It's used to prevent from accidentally choosing the storage card as a backup destination.
stop_dir="NIKON"

if [ -z "$1" ]; then
    dialog --erase-on-exit --backtitle "Error" --msgbox "Specify an identifier, e.g.:\n\n$0 CARD1" 9 32
    exit 1
fi

if [ ! -x "$(command -v rsync)" ] || [ ! -x "$(command -v dialog)" ] || [ ! -x "$(command -v curl)" ]; then
    apk update
    apk upgrade
    apk add rsync dialog curl
fi

# Prompt to choose a source directory, then mount it
mkdir -p "$1"
dialog --erase-on-exit --backtitle "Info" --msgbox "When prompted, choose the SOURCE directory." 7 30
mount -t ios . "$1"

# Promt to choose destination directory, then mount it
mkdir -p backup
dialog --erase-on-exit --backtitle "Info" --msgbox "When prompted, choose the DESTINATION directory." 7 30
mount -t ios . backup

# Destination check

if [ -d "backup/$stop_dir" ]; then
    dialog --erase-on-exit --backtitle "Warning" --msgbox "Incorrect destionation directory." 7 30
    exit 1
fi

rsync --progress --stats --modify-window=1 --update --recursive --times --delete "$1" "backup/"
umount "$1"
umount backup

if [ ! -z "$ntfy_topic" ]; then
    curl \
        -d "Backup completed. Have a nice day!" \
        -H "Title: Safe Travels" \
        "$ntfy_server/$ntfy_topic" >/dev/null 2>&1
fi
