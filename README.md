# BackThatNasUp

A versatile, configurable backup script designed to automate local and remote backups for clients or servers, organized by directory groupings defined in the configuration file.

This is still VERY much a work-in-progress. It backs stuff up via a config....that's all at the moment.

## Current functionality

- Will generate a configuration file when running script for the first time (with or without arguments).
- Will check to make sure all filepaths in config exist before running.
- Verify the local paths in config exist.
- Verify backup servers are up.
- Ability to run a dry-run to check what will be backed up with either a mirror or default backup.
- Ability to run a live-run with either a mirror or default backup.
- Ability to backup to all directories listed in the default directory group DIRECTORIES.
- Will backup to a user specified directory grouping in the configuration file.

## Requirements

- [rsync](https://github.com/RsyncProject/rsync) Utility that provides fast incremental file transfer. Required on both client and host.
- [SSH key pair](https://wiki.archlinux.org/title/SSH_keys) for backup server login. I have no intention of implementing password login.
- Any other unix based device that you want to backup from or to.

## Installation

To use btnu, follow the instructions below:

1. Clone the BackThatNasUp repository to your local machine using the command:

    `https://github.com/CtrlAltMech/BackThatNasUp.git`

2. Navigate to the cloned repository directory using the command `cd BackThatNasUp`
3. Make the btnu script executable using the command `chmod +x btnu.sh`
4. Run the script with `./btnu.sh` to create initial config file

## Usage

1. On the first use (when no config file is present) you will be prompted to generate an empty config file.

*Note: All ONSITE variables are required as well as at least one DIRECTORIES path*

```
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

```
*Be aware: references to your home directory in the conf file must be done with $HOME, not ~. $HOME is a shell variable, and ~ is an expansion symbol.*

2. Once the configuration file is created your editor should open to edit the file.
3. When the configuration file is filled out run you can run the script using one of the flags below.

## Flags :triangular_flag_on_post:
- `btnu.sh` - Will create a configuration file if none is present. If one is you will be presented with a help dialogue
- `btnu.sh -h` - Will prompt with help dialogue
- `btnu.sh -m` - Will run a dry-run of a mirror backup job
- `btnu.sh -M` - Will run a mirror backup job
- `btnu.sh -r` - Will run a dry-run backup without mirroring (-avzhpe rsync options)
- `btnu.sh -R` - Will run a backup without mirroring (-avzhpe rsync options)
- `btnu.sh -s <directory group name> <run-type>` - Will run backup on specified directory group
- `btnu.sh -L` - Will run with logging on. Needs to be combined with run type with or without group selection.

*MORE GRANULAR CONTROLS TO COME IN THE FUTURE*

## Configuration :open_book:
- Directory groups can be added to the configurtion file by adding another list under the DIRECTORY list.
- Follow the formatting of the DIRECTORY list and specify your own name.
- This group can be selected with the `-s` flag when running your backup.

## Contributing :handshake:
I would love to hear if there are any bugs or a requested feature! :heart:

If you would like to contribute to the btnu project, follow the instructions below:

1. Fork the BackThatNasUp repository to your Github account.
2. Clone your fork of the BackThatNasUp repository to your local machine.
3. Make your changes to the btnu script.
4. Push your changes to your fork of the BackThatNasUp repository.
5. Submit a pull request to the original BackThatNasUp repository.

## License

The btnu bash script is released under the GNU General Public License v3.0. See the LICENSE file for more information.
