#!/bin/bash

# Author: Dmitri Popov, dmpop@cameracode.coffee
# Source code: https://github.com/dmpop/ish-scripts

# ------- CONFIGURATION -------
local_dir="/path/to/source/dir"
remote_user="user"
remote_password="secret"
remote_server="hello.xyz"
remote_dir="/path/to/remote/dir"
# ------------------------------

if [ ! -x "$(command -v rsync)" ] || [ ! -x "$(command -v sshpass)" ]; then
    apk update
    apk upgrade
    apk add rsync sshpass
fi

mkdir -p "$local_dir"
mount -t ios . "$local_dir"

sshpass -p "$remote_password" rsync -avhz --exclude=".*" --info=progress2 --delete -P -e "ssh -p 22" \
    "$local_dir/" "$remote_user"@"$remote_server":"$remote_dir"

umount "$local_dir"