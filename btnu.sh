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
    # Only runs the actual backup if specified.
    # If anything other than -R is put, this will only do a dry-run
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
        conf_prompt
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

# If no configuration file is seen it will prompt to generate one 
conf_prompt () {
    local conf_choice
    read -p "$(echo -e "${YELLOW}No configuration file found. Would you like to create one? (y/n): ${ENDCOLOR}")" conf_choice
    
    while ! [[ $conf_choice =~ (^y$|^Y$|^n$|^N$) ]]
    do
        read -p "$(echo -e "${RED}Not a valid option. Would you like to create a config file? (y/n): ${ENDCOLOR}")" conf_choice
    done

    if [[ $conf_choice =~ (^y$|^Y$) ]]; then
        conf_make
    elif [[ "$conf_choice" =~ (^n$|^N$) ]]; then
        echo -e "${YELLOW}Goodbye!${ENDCOLOR}"
        exit 0
    fi
}


conf_make () {
	
	cat <<- EOF > "$CONFIG"
	# Config file for btnu
	
	# List of directories you want to backup.
	DIRECTORIES=(
		'/Example_directory/'
		'/Another/Example/'
		)
	
	# Meant to be a different host, but located locally
	# Enter IP or hostname.
	ONSITE_BACKUP_HOST=""
	
	# Path on the onsite host where the backup will be stored
	ONSITE_BACKUP_PATH=""
	
	# Username for onsite host
	ONSITE_USERNAME=""
	
	# Onsite host SSH priv key path
	ONSITE_SSHKEY_PATH=""
	
	# Meant to be a different host located offsite away from your onsite host.
	OFFSITE_BACKUP_HOST=""
	
	# Path on remote host where the backup will be stored
	OFFSITE_BACKUP_PATH=""
	
	# Username for offsite host
	OFFSITE_USERNAME=""
	
	# Offsite host SSH priv key path
	OFFSITE_SSHKEY_PATH=""
	
	EOF
    echo -e "${GREEN}Config file $CONFIG created!${ENDCOLOR}"
    $EDITOR $CONFIG # Open config in editor
    exit 0
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











