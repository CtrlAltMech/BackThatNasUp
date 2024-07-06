# BackThatNasUp
A configurable backup script to automate keeping your clients or servers backed up.

This is still VERY much a work in progress

# Broad strokes
Just a place for me to get the overall idea down to so I stay on track.
- Configuration file defining...
  * What directories you want backed up (However many that may be) ***Set a list in configuration file***
  * Option to pass encryption parameters (Drive on the other end needs to be unlocked?)
  * SSH key filepaths ***Added variable to hold path to key***
  * Defining a secondary server to push the most recent push to (Like a local and remote backup) ***Added variable to hold remote server info***
  * Probably not happening any time soon, but looking into keeping a set amount of old backups and defining that structure in the config file.
  * Other stuff I forgot I thought of last night
- Command line arguments allowing you to run things to bypass the config file if wanted and other stuff like just running a dry run

# Current state
- It has the ability to take anything from the configuration file and use that information to backup to a single location.
- By default it will run a dry-run option. It wont actually run a backup unless you specify the -R flag.

yada yada yada
