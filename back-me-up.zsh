#!/usr/bin/env zsh
#: Description : Back up user settings and important works automatically.
#: Version     : 0.0.1
#: Author      : "Aurélien Plazzotta <aurelien.plazzotta@protonmail.com>"
#: Options     : --upload - Upload back up to remote host
#:             : -v       - Print version number
#:+ See `anon_transfer.zsh` for details related to the uploaded back up.

#  Add the following into '.zshrc' to cause this script to be a cron job (i.e. executed at boot)
#+ `@reboot /home/aurele/dev/zsh/backmeup.zsh`
#+ Make BOTH this script and `/etc/rc.d/rc.local` executables with `chmod +x`

DEST_DIR="${HOME}/back_up/"
NAME="$1"
REMOTE="123.65.23.85" # Alter it with my mutualized server's IP

case "$#" in
    1) ;; # Do nothing as we expect exactly 1 argument.
    *) printf %s\\n "Please provide a name for your back up." >&2
       exit 1
       ;;
esac

# Explain usage when user omit argument when --upload option is invoked.
if [ -z "$REMOTE" -o]; then
    echo "usage: $0 <remote>" >&2
    exit 1
fi

NEW_SAVE="${DEST_DIR}/${NAME}-$(date -I'minutes')"
mkdir "$NEW_SAVE"

alias rsync='rsync -axAXH'

rsync --info=progress2 --files-from=file-list --exclude-from=exclude "$DEST_DIR"

for dossier in "${HOME}/dev/**"; do # Does pattern (i.e. clobber) work in `for` loop?
    if [ -d '.git' ]; then
        git archive "${HOME}/dev/${dossier}" "${DEST_DIR}/dev/${dossier}"
        # Hooks are not automatically saved bit git clone or git archive
        rsync "${HOME}/dev/${dossier}/.git/hook" "${DEST_DIR}/dev/${dossier}/.git/hook"
    fi
done

tar -cJf "${NEW_SAVE}.tar.xz" "$NEW_SAVE"
rm -f "$NEW_SAVE"
if '--upload' option; then # See p. 39/40 and p. 114/115 from Pro Bash Programming
    ftp $REMOTE
    rsync --password-file="${HOME}/.passwd" \
        "${DEST_DIR}/${NEW_SAVE}.tar.xz" "domihyyk@199.59.247.89:/back_up/"
fi
exit 0

#  TODO:
#  1) Back up also Xfce shortcuts
#  2) Back up terminal settings
#  4) Add a `-y` option `if ($1 OR $2 == -y OR --yes); then` to cause the script to stay in
#+ non-interactive mode.
#  5) Prompt the user when invoked with `[--add | --edit | --remove]` to add/edit/remove
#+ used-defined directories. Write the changes to an external file to make the script always
#+ synchronized with my needs.
# 6) Convert the current script into Zig language.
# 7) Add a `--email` option for weekly reporting.
# 8) Add a -v option (see page 39/40 and 114/115 from Pro Bash Programming).