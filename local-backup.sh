#!/bin/bash

# Author: Dmitri Popov, dmpop@cameracode.coffee
# Source code: https://github.com/dmpop/ish-scripts

if [ -z "$1" ]; then
    echo "Specify a directory name"
    exit 1
fi

if [ ! -x "$(command -v rsync)" ]; then
    apk update
    apk upgrade
    apk add rsync
fi

mkdir -p "$1"
mount -t ios . "$1"
mkdir -p backup
mount -t ios . backup

rsync -av --info=progress2 --delete "$1" "backup/"
umount "$1"
umount backup
