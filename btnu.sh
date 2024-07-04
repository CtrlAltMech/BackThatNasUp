#!/bin/bash

readonly CONFIG="$HOME/git_repos/BackThatNasUp/config"

echo "$CONFIG"

. "$CONFIG"


for i in $DIRECTORIES; do
    echo "$i"
done

rsync --dry-run -avzhpe ssh /mnt/user/Music mech@thiccpad:/media/veracrypt2/

