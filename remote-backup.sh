#!/bin/bash

# Author: Dmitri Popov, dmpop@cameracode.coffee
# Source code: https://github.com/dmpop/safe-travels

# ------- CONFIGURATION -------
remote_user="user"
remote_password="secret"
remote_server="hello.xyz"
remote_dir="/path/to/remote/dir"
# Specify ntfy_topic to enable ntfy.sh notifications
ntfy_server="ntfy.sh"
ntfy_topic=""
# ------------------------------

if [ ! -x "$(command -v rsync)" ] || [ ! -x "$(command -v sshpass)" ] || [ ! -x "$(command -v dialog)" ]; then
    apk update
    apk upgrade
    apk add rsync sshpass dialog
fi

mnt="backup"
mkdir -p "$mnt"
dialog --erase-on-exit --backtitle "Info" --msgbox "When prompted, choose the LOCAL folder." 7 30
mount -t ios . "$mnt"

sshpass -p "$remote_password" rsync -avhz --exclude=".*" --info=progress2 --delete -P -e "ssh -p 22" \
    "$mnt/" "$remote_user"@"$remote_server":"$remote_dir"

umount "$mnt"

if [ ! -z "$ntfy_topic" ]; then
    curl \
        -d "Backup completed. Have a nice day!" \
        -H "Title: Message from iSH" \
        "$ntfy_server/$ntfy_topic" >/dev/null 2>&1
fi
