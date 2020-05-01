# dotfiles-scripts

This repository contains scripts to manage dotfiles. All scripts assume that
this directory contains all dotfiles to be installed in a file structure
corresponding to `~`, for example `./.vimrc` will correspond to `~/.vimrc` and
`./.config/dunst/dunstrc` will correspond to `~/.config/dunst/dunstrc`. For some
scripts, these directories can be reconfigured using options.

- `install.sh`: for all files in this directory except paths listed in
	`.install_ignore`, this script:
	1. backs up corresponding files from `~` to
		`.dotfiles_backup`
	2. make symlinks in `~` to this directory
- `uninstall.sh`: undoes what `install.sh` does, restoring backups when present
	and doing nothing otherwise (it can delete symlinks if there is no backup
	with the option `-d`
- `extract.sh`: copies a new dotfile to this directory and make the old path a
	symlink to this directory's copy
- `unlink.sh`: undoes what `extract.sh` does

## Usage Examples

### New system

Ensure all dotfiles wanted are in this directory, then run

	./install.sh

from this directory.

### Restore original dotfiles

Simply run

	./uninstall.sh

from this directory. This will remove all symlinks and restore from the backup
if the original dotfiles were overwritten.

If we want to leave no traces, removing even dotfiles that
did not have an original, run

	./uninstall.sh -d

### Add new dotfiles to this system

To add, for example, `~/.config/dunst/dunstrc` to this system, run

	./extract.sh -f .config/dunst/dunstrc

To undo this, removing `./.config/dunst/dunstrc` and returning the original file
to `~`, run

	./unlink.sh -f .config/dunst/dunstrc

## Development History

Initial development was carried out at
[chuahou/dotfiles](https://github.com/chuahou/dotfiles).
