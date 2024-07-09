#!/usr/bin/env bash
#
# backthatnasup(btnu)
#
# A script to deal with adhoc backups as well
# as scheduled backups when paired with
# a cron job. All parameters to be configured
# via a configuration file found in your '.config'
# directory.
#
# by CtrlAltMech
#

# Exit on error
set -e

# Configuration file to source from
readonly CONFIG="$HOME/.config/btnurc"

# Output Colors
readonly RED="\e[31m"
readonly GREEN="\e[32m"
readonly YELLOW="\e[33m"
readonly CYAN="\e[36m"
readonly ENDCOLOR="\e[0m"


# Main Logic
main () {
    conf_check
    conf_var_check
    if [[ $1 == "-R" ]]; then
        rsync_job
    else
        rsync_job "--dry-run"
    fi
}

# Check for configuration file
conf_check () {
    if  [[ -e $CONFIG ]]; then
        # shellcheck source=../../.config/btnurc
        . "$CONFIG"
    else
        echo "Can't find that shit!"
        exit 1
    fi
}

# Check to make sure the bare-minimum config variables are set.
conf_var_check () {
    local msg="$(echo -e "${RED}ONSITE variables and at least one directory need to be set in config.${ENDCOLOR}")"
    : "${DIRECTORIES:?$msg}"
    : "${ONSITE_BACKUP_HOST:?$msg}"
    : "${ONSITE_BACKUP_PATH:?$msg}"
    : "${ONSITE_USERNAME:?$msg}"
    : "${ONSITE_SSHKEY_PATH:?$msg}"
}

# Handles the actual running of rsync job based on parameters passed to it. More functionality to come.
rsync_job () {
    if [[ $1 == "--dry-run" ]]; then
        for dir in "${DIRECTORIES[@]}"
        do
            rsync --dry-run -avzhpe "ssh -i $ONSITE_SSHKEY_PATH" "$dir" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST":"$ONSITE_BACKUP_PATH" 
        done
    elif [[ $1 == "" ]]; then
        for dir in "${DIRECTORIES[@]}"
        do
            rsync -avzhpe "ssh -i $ONSITE_SSHKEY_PATH" "$dir" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST":"$ONSITE_BACKUP_PATH" 
        done
    else
        exit 1
    fi
}

main "$@"











