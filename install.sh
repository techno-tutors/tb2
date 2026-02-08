#!/usr/bin/env bash
set -euo pipefail

ESC="\033["
RESET="${ESC}0m"
BOLD="${ESC}1m"
BLUE="${ESC}34m"
YELLOW="${ESC}33m"
RED="${ESC}31m"
GREEN="${ESC}32m"

log() { printf "%b" "[+] $1\n"; }
info() { printf "%b" "${BLUE}${BOLD}[*]${RESET} $1\n"; }
warn() { printf "%b" "${YELLOW}${BOLD}[!]${RESET} $1\n"; }
error() { printf "%b" "${RED}${BOLD}[-]${RESET} $1\n"; }
ask() {
  local __var="$1"
  shift
  printf "%b" "${BOLD}${GREEN}[?]${RESET} $*\n ${BOLD}${GREEN}>>${RESET} "
  if ! read -r answer </dev/tty; then
    error "No interactive input available."
    exit 1
  fi
  eval "$__var=\"$(printf "%s" "$answer")\""
}

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
  eval "$*"
  catch $?
  set -e
  return $?
}

step() {
  printf "%b" "${BLUE}${BOLD}-----[ step $1/$2 ]----------------------------------------${RESET}\n"
}

TOTAL=11

step 1 $TOTAL
info "Moving to temporary directory"
run cd /tmp

step 2 $TOTAL
info "Checking for existing tb2 directory"
if [ -d tb2 ]; then
  warn "Existing tb2 directory found. Removing it."
  run rm -rf tb2
fi

step 3 $TOTAL
info "Cloning tb2 repository"
run git clone https://github.com/techno-tutors/tb2.git

step 4 $TOTAL
info "Entering tb2 directory"
run cd tb2

step 5 $TOTAL
info "Applying executable permissions to script files"
find script -type f -print0 | xargs -0 chmod 755
log "Permissions applied"

step 6 $TOTAL
info "Selecting installation target"
echo " 0) /usr/local/bin + /usr/local/share"
echo " 1) ~/.local/bin + ~/.local/share"

choice=""
ask choice "Choose installation target (0 or 1)"
if [ "$choice" != "0" ] && [ "$choice" != "1" ]; then
  error "Invalid choice"
  exit 1
fi

step 7 $TOTAL
if [ "$choice" = "0" ]; then
  info "Preparing system-wide directories"
  run sudo mkdir -p /usr/local/share/tb2
  run sudo mkdir -p /usr/local/bin
else
  info "Preparing user directories"
  run mkdir -p ~/.local/share/tb2
  run mkdir -p ~/.local/bin
fi

step 8 $TOTAL
info "Copying tb2 files"
if [ "$choice" = "0" ]; then
  run sudo cp -r ./* /usr/local/share/tb2/
else
  run cp -r ./* ~/.local/share/tb2/
fi

step 9 $TOTAL
info "Permission setting..."
run sudo chmod -R a+rx /usr/local/share/tb2


step 10 $TOTAL
info "Creating symlink"
if [ "$choice" = "0" ]; then
  run sudo ln -sf /usr/local/share/tb2/script/tb2 /usr/local/bin/tb2
else
  run ln -sf ~/.local/share/tb2/script/tb2 ~/.local/bin/tb2
fi

step 11 $TOTAL
log "Installation complete."
exit 0
