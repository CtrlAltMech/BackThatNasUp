# BackThatNasUp

A configurable backup script to automate keeping your clients or servers backed up locally and remotely.

This is still VERY much a work-in-progress. It backs stuff up via a config....that's all at the moment.

## Current functionality

- Will generate a configuration file when running script for the first time.
- Will check to make sure all filepaths in config exist before running
- Will backup to all directories listed in the configuration file
- Will run a dry-run to verify backups and can run the actual backup if the flag is set.

## Requirements

- [rsync](https://github.com/RsyncProject/rsync) Utility that provides fast incremental file transfer. Required on both client and host.
- [SSH key pair](https://wiki.archlinux.org/title/SSH_keys) for backup server login. I have no intention of implementing password login.
- Any other unix based device that you want to backup from or to.

## Installation

To use btnu, follow the instructions below:

1. Clone the sspush repository to your local machine using the command:

    `https://github.com/CtrlAltMech/BackThatNasUp.git`

2. Navigate to the cloned repository directory using the command `cd BackThatNasUp`
3. Make the sspush script executable using the command `chmod +x btnu.sh`
4. Run the script with `./btnu.sh`

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
3. When the configuration file is filled out run the `./btnu.sh` command again to do a dry run of your backup
4. Once that looks like it is correct run `./btnu.sh -R` to run the backup

## Flags :triangular_flag_on_post:
- `btnu.sh` - will just run a dry-run of your directories so you can verify what will be backed up
- `btnu.sh -R` - will run your backups

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
