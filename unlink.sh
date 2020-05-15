#!/bin/bash
#
# reinstates an extracted [FILE] relative to [HOME] from [DOTFILES]
#
# ./unlink.sh -f(ile) [FILE] -o(utput) [HOME] -d(irectory) [DOTFILES] -n(olink)

set -e

print_usage ()
{
	echo "Usage: ./unlink.sh -f [FILE] -o [HOME] -d [DOTFILES] -n"
	echo "    [FILE]: file to reinstate, filename relative to [HOME]"
	echo "    [HOME]: base directory (usually ~) [FILE] is relative to"
	echo "    [DOTFILES]: directory to reinstate from (usually ~/.dotfiles)"
	echo "    -n: don't check that ~/FILE links to DOTFILES/FILE"
}

abort ()
{
	read USERINPUT
	if [ ! "$USERINPUT" = "y" ]; then
		echo "Aborting."
		exit 1
	fi
}

# defaults
ARGHOME=$HOME
ARGDOTS=$(dirname $0)

# get options
while getopts 'f:d:o:n' OPTION; do
	case "$OPTION" in
		f)
			ARGFILE="$OPTARG"
			;;
		d)
			ARGDOTS="$OPTARG"
			;;
		o)
			ARGHOME="$OPTARG"
			;;
		n)
			ARGNOLINK="yes"
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
INFILE="$ARGDOTS/$ARGFILE"
OUTFILE="$ARGHOME/$ARGFILE"

# check output file does exist
if [ ! -e "$OUTFILE" ]; then
	echo "$OUTFILE does not exist, really unlink? (y to proceed, otherwise to cancel)"
	abort
else # if exists, ensure it is linked to input file unless ARGNOLINK is set
	if [ -z "$ARGNOLINK" ]; then
		if [ $(realpath $OUTFILE) != $(realpath $INFILE) ]; then
			echo "$OUTFILE does not link to $INFILE, really unlink? (y to proceed, otherwise to cancel)"
			abort
		fi
	fi

	# remove output file
	rm $OUTFILE
fi

# move input file
mkdir -p $(dirname $OUTFILE)
mv $INFILE $OUTFILE
echo "Reinstated $INFILE -> $OUTFILE"
