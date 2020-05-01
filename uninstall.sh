#!/bin/bash
#
# undoes install.sh run with same arguments, -d to delete non backed up files
#
# ./uninstall.sh -o(utput) [HOME] -i(gnore) [IGNORE] -b(ackup) [BACKUP] -d(elete)

set -e

print_usage ()
{
	echo "Usage: ./install.sh -o [HOME] -i [IGNORE] -b [BACKUP] -d"
	echo "    [HOME]: base directory (usually ~) to install symlinks in"
	echo "    [IGNORE]: file with paths to ignore"
	echo "    [BACKUP]: directory to backup to"
	echo "    -d: delete files without backups"
}

# defaults
ARGHOME=$HOME
ARGIGNORE=.install_ignore
ARGBACKUP=$(pwd)/.dotfiles_backup

# get options
while getopts 'o:i:b:d' OPTION; do
	case "$OPTION" in
		o)
			ARGHOME="$OPTARG"
			;;
		i)
			ARGIGNORE="$OPTARG"
			;;
		b)
			ARGBACKUP="$OPTARG"
			;;
		d)
			ARGDELETE="yes"
			;;
		?)
			print_usage
			exit 1
			;;
	esac
done

# ensure home directory exists and is directory
if [ ! -d "$ARGHOME" ]; then
	>&2 echo "$ARGHOME is not a directory"
	exit 1
fi

# ensure ignore file is a valid file
if [ ! -e "$ARGIGNORE" ]; then
	>&2 echo "$ARGIGNORE could not be read"
	exit 1
fi

# ensure backup directory exists
if [[ ! "$ARGBACKUP" =~ ^/ ]]; then # check if ARGBACKUP is absolute path
	ARGBACKUP=$(pwd)/$ARGBACKUP # if not, make it absolute relative to pwd
fi

# get list of dotfiles with absolute path
IGNOREFILES=$(cat $ARGIGNORE | \
	sed -r "s|/\./|/|g" | \
	sed -r "s|^\./||g") # get paths to ignore and remove excess "./"s
DOTFILES=$(echo "$IGNOREFILES" | \
	xargs printf "! -path ./%s " | \
	xargs find . -type f | \
	sed -r "s|^\./||g") # get paths of DOTFILES and ignore paths, then remove ./

# loop through each dotfile
for DOTFILE in $DOTFILES; do
	# generate full paths
	HOMEPATH=$ARGHOME/$DOTFILE # path of file in [HOME]
	DOTPATH=$(pwd)/$DOTFILE # path of file in .
	BACKUPPATH=$ARGBACKUP/$DOTFILE # path of backup

	# check backup exists
	if [ ! -e "$BACKUPPATH" ]; then
		if [ -n "$ARGDELETE" ]; then # delete file without backup if is symlink
			if [[ -L "$HOMEPATH" ]]; then
				rm $HOMEPATH
			fi
		else
			>&2 echo "$BACKUPPATH does not exist, not restoring $HOMEPATH"
		fi
	elif [[ -L "$BACKUPPATH" ]]; then
		>&2 echo "$BACKUPPATH is symlink, not restoring $HOMEPATH"
	else
		./unlink.sh -f $DOTFILE -o $ARGHOME -d $ARGBACKUP -n
	fi
done
