#!/usr/bin/env bash
set -euo pipefail

ESC="\033["
RESET="${ESC}0m"
BOLD="${ESC}1m"
BLUE="${ESC}34m"
RED="${ESC}31m"

log() { printf "%b" "[+] $1\n"; }
info() { printf "%b" "${BLUE}${BOLD}[*]${RESET} $1\n"; }
error() { printf "%b" "${RED}${BOLD}[-]${RESET} $1\n"; }
catch() {
  if [ "$1" -ne 0 ]; then
    error "Command failed with exit code $1."
    return 2
  else
    info "Command executed successfully."
    return 0
  fi
}
run() {
  info "Running> $*"
  trap 'set -e' EXIT
  set +e
  "$@"
  catch $?
  set -e
  return $?
}

step() {
  printf "%b" "${BLUE}${BOLD}-----[ step $1/$2 ]----------------------------------------${RESET}\n"
}

TOTAL=6

step 1 $TOTAL
info "Detecting installation target"
if [ -f /usr/local/bin/tb2 ]; then
  target="system"
elif [ -f ~/.local/bin/tb2 ]; then
  target="user"
else
  error "tb2 is not installed"
  exit 1
fi
log "Detected: $target install"

step 2 $TOTAL
info "Preparing temporary workspace"
run rm -rf /tmp/tb2-update
run mkdir -p /tmp/tb2-update
run cd /tmp/tb2-update

step 3 $TOTAL
info "Cloning latest tb2"
run git clone https://github.com/techno-tutors/tb2.git
run cd tb2

step 4 $TOTAL
info "Applying permissions"
find script -type f -print0 | xargs -0 chmod 755

step 5 $TOTAL
info "Updating installation"
if [ "$target" = "system" ]; then
  run sudo rm -rf /usr/local/share/tb2
  run sudo mkdir -p /usr/local/share/tb2
  run sudo cp -r script/* /usr/local/share/tb2/
  run sudo ln -sf /usr/local/share/tb2/tb2 /usr/local/bin/tb2
else
  run rm -rf ~/.local/share/tb2
  run mkdir -p ~/.local/share/tb2
  run cp -r script/* ~/.local/share/tb2/
  run ln -sf ~/.local/share/tb2/tb2 ~/.local/bin/tb2
fi

step 6 $TOTAL
log "Update complete."
exit 0
