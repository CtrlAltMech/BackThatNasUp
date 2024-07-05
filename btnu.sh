#!/bin/bash

set -e

readonly CONFIG="$HOME/git_repos/BackThatNasUp/config"

# shellcheck source=./config 
. "$CONFIG"

# Loops through the list of directories I have in my config file and backs them up.
# dry-run flag set for testing
for i in "${DIRECTORIES[@]}" 
do
    rsync --dry-run -avzhpe "ssh -i $ONSITE_SSHKEY_PATH" "$i" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST":"$ONSITE_BACKUP_PATH" 
done

#rsync --dry-run -avzhpe ssh /mnt/user/Music mech@thiccpad:/media/veracrypt2/

