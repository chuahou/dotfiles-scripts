#!/bin/bash
#
# extracts an existing [FILE] relative to [HOME] to the [DOTFILES] directory
#
# ./extract.sh -f(ile) [FILE] -d(irectory) [HOME] -o(utput) [DOTFILES]

set -e

print_usage ()
{
	echo "Usage: ./extract.sh -f [FILE] -d [HOME] -o [DOTFILES]"
	echo "    [FILE]: file to extract, filename relative to [HOME]"
	echo "    [HOME]: base directory (usually ~) [FILE] is relative to"
	echo "    [DOTFILES]: directory to extract to (usually ~/.dotfiles)"
}

# defaults
ARGHOME=$HOME
ARGDOTS=$HOME/.dotfiles

# get options
while getopts 'f:d:o:' OPTION; do
	case "$OPTION" in
		f)
			ARGFILE="$OPTARG"
			;;
		d)
			ARGHOME="$OPTARG"
			;;
		o)
			ARGDOTS="$OPTARG"
			;;
		?)
			print_usage
			exit 1
			;;
	esac
done

# ensure file provided
if [ -z "$ARGFILE" ]; then
	print_usage
	exit 1
fi

# check if ARGFILE is an absolute path and make it relative to ARGHOME
if [[ "$ARGFILE" =~ ^/ ]]; then
	# strip ARGHOME from start of path and remove /
	ARGFILE=$(echo $ARGFILE | sed "s|^${ARGHOME}/\?||g")

	# if there's still a slash, ARGFILE is not in ARGHOME
	if [[ "$ARGFILE" =~ ^/ ]]; then
		>&2 echo "ERROR: $ARGFILE not in $ARGHOME"
		exit 1
	fi
fi

# check if ARGDOTS is an absolute path and if not make it one
if [[ ! "$ARGDOTS" =~ ^/ ]]; then
	ARGDOTS="$(pwd)/$ARGDOTS"
fi

# calculate absolute paths for input and output file
TARGETFILE="$ARGDOTS/$ARGFILE"
ARGFILE="$ARGHOME/$ARGFILE"

# check output file does not exist
if [ -e "$TARGETFILE" ]; then
	echo "$TARGETFILE exists, overwrite? (y to proceed, otherwise to cancel)"
	read USERINPUT
	if [ "$USERINPUT" != "y" ]; then
		echo "Aborting."
		exit
	fi
	rm $TARGETFILE
fi

# move input file
mkdir -p $(dirname $TARGETFILE)
mv $ARGFILE $TARGETFILE

# symlink old file to this file
ln -s $TARGETFILE $ARGFILE
echo "Extracted $ARGFILE -> $TARGETFILE"
