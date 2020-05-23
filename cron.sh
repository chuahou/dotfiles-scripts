#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2020 Chua Hou
# Copies current crontab file to ./cron or vice versa.
#
# ./cron.sh install|extract

set -e

print_usage ()
{
	echo "Usage: ./cron.sh install|extract"
	echo "    install: installs ./cron"
	echo "    extract: gets current crontab and copies to ./cron"
}

# path to cron is relative to script
CRON_FILENAME=$(dirname "$0")/cron

# check argument number
if [ $# -ne 1 ]; then
	print_usage
fi

# install / extract
case $1 in
	'install')
		echo "Installing crontab..."
		crontab $CRON_FILENAME
		;;
	'extract')
		echo "Extracting crontab to $CRON_FILENAME..."
		crontab -l > $CRON_FILENAME
		;;
	*)
		print_usage
		;;
esac
