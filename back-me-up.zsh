#!/usr/bin/env zsh
#:  Description : Back up user settings and important works automatically.
#:+ Create a local archive from the copied files AND upload it to my mutualized server.
#:+ See `anon_transfer.zsh` for details related to the uploaded back up.

#  Add the following into '.zshrc' to cause this script to be a cron job (i.e. executed at boot)
#+ `@reboot /home/aurele/dev/zsh/backmeup.zsh`
#+ Make BOTH this script and `/etc/rc.d/rc.local` executables with `chmod +x`

# MYDIR="$(dirname $0)"
DEST_DIR="${HOME}/back_up/"
NAME="$1"
REMOTE="123.65.23.85" # Alter it with my mutualized server's IP

case "$#" in
    1) ;; # Do nothing as we expect exactly 1 argument.
    *) printf %s\\n "Please provide a name for your back up." >&2
       exit 1
       ;;
esac

NEW_SAVE="${DEST_DIR}/${NAME}-$(date -I'minutes')"
mkdir "$NEW_SAVE"

alias rsync='rsync -axAXH'

rsync -r --files-from=file-list "$DEST_DIR"

for dossier in "${HOME}/dev/**"; do # Does pattern (i.e. clobber) work in `for` loop?
    if [ -d '.git' ]; then
        rsync "${HOME}/dev/${dossier}/.git/{config,info}" "$DEST_DIR"
    fi
done

tar -cJf "${NEW_SAVE}.tar.xz" "$NEW_SAVE"
rm -f "$NEW_SAVE"
# if upload option; then
    ftp $REMOTE
    rsync --password-file="${HOME}/.passwd" \
        "${DEST_DIR}/${NEW_SAVE}.tar.xz" "domihyyk@199.59.247.89:/back_up/"
#fi
exit 0

#  TODO:
#  1) Back up also Xfce shortcuts
#  2) Back up terminal settings
#  3) Add an `--upload` option to also upload the data to your personal server
#  4) Add a `-y` option `if ($1 OR $2 == -y OR --yes); then` to cause the script to stay in
#+ non-interactive mode.
#  5) Prompt the user when invoked with `[--add | --edit | --remove]` to add/edit/remove
#+ used-defined directories. Write the changes to an external file to make the script always
#+ synchronized with my needs.
# 6) Convert the current script into Zig language.
# 7) Add a `--email` option for weekly reporting.
# 8) Add a -v option (see page 39/40 from Pro Bash Programming).