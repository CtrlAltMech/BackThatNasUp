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

# Option variables
selected_dir_group="" # Selected group of file paths go here
job_run_type="" # Tells us whether this is a mirror job or some other type (Only 2 types for now, mirror and not)
run_check="" # Is the job a dry-run or not
log_option=false # Save a log file if option set
remote_push_type="" # Sets the type of remote push specified

# Main Logic
main () {
    conf_check # Checks to make sure a config exists
    conf_var_check # Makes sure the bare minimum configuration variables are set
    opt_check "$@" # Checks for conflicing options set on command

    while getopts ":mMrRhLP:s:" OPTION;
    do
        case "$OPTION" in
            M) job_run_type="--delete";; # Run mirror job mirroring source directory. Can't be ran -m or -M option.
            R) :;; # Regular run with no-mirroring of source directory. Can't be ran if -M or -m option set.
            m) job_run_type="--delete"; run_check="--dry-run";; # Dry run of mirror job
            r) run_check="--dry-run";; # Dry run of run job
            s) selected_dir_group="$OPTARG";; # Set the variable for the selected group.
            L) log_option=true;; # Set true if we want to save logs
            P) remote_push_type="$OPTARG";; # Set the remote push type
            h) help_prompt;;
            :) echo -e "${RED}-"$OPTARG" requires an argument${ENDCOLOR}" && exit 1;;
            ?) echo -e "${RED}Invalid argument passed.${ENDCOLOR}" && exit 1;;
        esac
    done

    var_group_check "$selected_dir_group"
    conf_path_check "$selected_dir_group"
    if [[ $log_option = false ]]; then # Runs without logging since -L flag was not passed
        rsync_job "$selected_dir_group" "$job_run_type" "$run_check"
    else # Run with logging since -L flag was passed
        rsync_job "$selected_dir_group" "$job_run_type" "$run_check" | tee "${LOG_PATH}backup$(date +"%Y%m%d_%H%M%S").txt"
    fi
    
    remote_push
#    if [[ -z $remote_push_type ]]; then remote_push; fi
}

# Remote push function
remote_push () {
    # local push_type="$1"
    # local remote_push_command="touch test6 && echo test2"
    # remote_push_command="rsync -avzhpPe \"ssh -i ~/.ssh/id_thiccpad\" /mnt/backup_drive_test/screenshots mech@192.168.102.219:/home/mech"
    local remote_push_command="rsync -avzhpPe 'ssh -i $OFFSITE_SSHKEY_PATH' /mnt/backup_drive_test/screenshots mech@192.168.102.219:/home/mech"   # remote_push_command="rsync -avzhpPe 'ssh -i /home/mech/.ssh/id_thiccpad' /mnt/backup_drive_test/screenshots mech@192.168.102.219:/home/mech"
#rsync -avzhpPe "ssh -i /home/mech/.ssh/id_thiccpad" /mnt/backup_drive_test/screenshots/ mech@192.168.102.219:/home/mech
    # rsync ${3:+"$3"} ${2:+"$2"} "$rsync_ops" "ssh -i $ONSITE_SSHKEY_PATH" "$dir" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST":"$ONSITE_BACKUP_PATH"
    # local remote_connection="ssh -i $OFFSITE_SSHKEY_PATH $OFFSITE_USERNAME@$OFFSITE_BACKUP_HOST 'touch test5 && echo test'"
    # remote_connection="ssh -i '$OFFSITE_SSHKEY_PATH' '$OFFSITE_USERNAME'@'$OFFSITE_BACKUP_HOST' \"$remote_push_command\""
    # remote_connection="ssh -i '$OFFSITE_SSHKEY_PATH' '$OFFSITE_USERNAME'@'$OFFSITE_BACKUP_HOST'"


    # ssh -i "$ONSITE_SSHKEY_PATH" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST" "rsync -avzhpPe 'ssh -i $OFFSITE_SSHKEY_PATH' /mnt/backup_drive_test/screenshots mech@192.168.102.219:/home/mech"
    ssh -i "$ONSITE_SSHKEY_PATH" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST" "$remote_push_command"
#    "ssh -i $OFFSITE_SSHKEY_PATH $OFFSITE_USERNAME@$OFFSITE_BACKUP_HOST 'touch test4.txt && echo ls'"
}

# Help prompt
help_prompt () {
    :
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
    local msg="$(echo -e "${RED}ONSITE and LOG_PATH variables and at least one directory need to be set in config.${ENDCOLOR}")"
    : "${DIRECTORIES:?$msg}"
    : "${ONSITE_BACKUP_HOST:?$msg}"
    : "${ONSITE_BACKUP_PATH:?$msg}"
    : "${ONSITE_USERNAME:?$msg}"
    : "${ONSITE_SSHKEY_PATH:?$msg}"
    : "${LOG_PATH:?$msg}"
}

# Check to make sure the selected directories on the host are valid and formatted properly.
conf_path_check () {
    echo -e "\n${CYAN}Checking filepaths...${ENDCOLOR}\n"
    local dir_group="$1"
    [ -z "$dir_group" ] && dir_group="DIRECTORIES"
    eval "selected_group=(\"\${${dir_group}[@]}\")"
    for path in "${selected_group[@]}"
    do
        echo "$path"
    done    
    
    # Verifies LOG_PATH ends in a '/'
    # since we're concatenating the path with the name of the generated file
    local log_path_len=${#LOG_PATH}
    local last_char=${LOG_PATH:log_path_len-1:1}
    if [[ $last_char != '/' ]]; then
        LOG_PATH=$LOG_PATH'/'
    fi
    echo -e "\n${GREEN}All filepaths are valid!${ENDCOLOR}\n------------------------\n"
}

# Check to make sure the group you select actually exists. Exit if not.
var_group_check () {
    local dir_group="$1"
    [[ -z "$dir_group" ]] && dir_group="DIRECTORIES"
    if [[ -v "$dir_group" ]]; then
        :
    else
        echo -e "${RED}Directory group does not exist${ENDCOLOR}"
        exit 1
    fi

}

# Checks to make sure that conflicting options are not passed. Can be expanded later if needed.
opt_check () {
    local run=""
    local mirror=""
    for arg in "$@";
    do
       if [[ "$arg" =~ ^-[rR]$ ]] && [[ -z "$run" ]]; then
           run="$arg"
       elif [[ -n "$run" ]] && [[ "$arg" =~ ^-[rR]$ ]]; then
           echo "Conflicting run argument, can only have dry-run or live-run"
           exit 1
       elif [[ "$arg" =~ ^-[mM]$ ]] && [[ -z "$mirror" ]]; then
           mirror="$arg"
       elif [[ -n "$mirror" ]] && [[ "$arg" =~ ^-[mM]$ ]]; then
           echo "Conflicting run argument, can only have dry-mirror or live-mirror"
           exit 1
       elif [[ "$arg" =~ ^-[a-zA-Z]{2,}$ ]]; then
           echo "TOO MANY CHARACTERS"
           exit 1
       else
           :
       fi
    done
    if [[ -n "$run" && -n "$mirror" ]]; then
        echo -e "${RED}You can't have both -r and -m options. Choose run OR mirror${ENDCOLOR}"
        exit 1
    elif [[ -z "$run" && -z "$mirror" ]] || [[ "$1" == "$2" ]]; then
        echo "Improper argument setup passed (placeholder for help menu)"
        exit 1
    else
        :
    fi
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

# Ping command to verify if server is online
host_ping () {
    for server in "$@"
    do
        if timeout 2 ping -c 1 "$server" &> /dev/null; then
            echo -e "${GREEN}$server looks to be up!${ENDCOLOR}"
        else
            echo -e "${RED}$server looks to be down :(${ENDCOLOR}"
            exit 1
        fi
    done
}

# Check to make sure your onsite/offsite/both server/s are up.
check_server_alive () {
    echo -e "${CYAN}Checking server status...${ENDCOLOR}\n"
    if [[ "$OFFSITE_BACKUP_HOST" != "" ]]; then
        host_ping "$ONSITE_BACKUP_HOST" "$OFFSITE_BACKUP_HOST"
        echo ""
    else
        host_ping "$ONSITE_BACKUP_HOST"
        echo ""
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
	# Path to put log files
	LOG_PATH=""
	
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
    local readonly rsync_ops="-avzhPpe"
    local dir_group="$1"
    [ -z "$dir_group" ] && dir_group="DIRECTORIES"
    eval "selected_group=(\"\${${dir_group}[@]}\")"

    if [[ $3 == "--dry-run" ]]; then
        for dir in "${selected_group[@]}"
        do
            echo -e "${YELLOW}Running DRY-RUN backup on $dir ${ENDCOLOR}"
            rsync ${3:+"$3"} ${2:+"$2"} "$rsync_ops" "ssh -i $ONSITE_SSHKEY_PATH" "$dir" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST":"$ONSITE_BACKUP_PATH"
            echo ""
        done
    else
        for dir in "${selected_group[@]}"
        do
            echo -e "${CYAN}Running backup on $dir ${ENDCOLOR}"
            rsync ${3:+"$3"} ${2:+"$2"} "$rsync_ops" "ssh -i $ONSITE_SSHKEY_PATH" "$dir" "$ONSITE_USERNAME"@"$ONSITE_BACKUP_HOST":"$ONSITE_BACKUP_PATH"
            echo ""
        done
    fi
}

# Run the script
main "$@"











