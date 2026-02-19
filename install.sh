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
echo " 0) /usr/local/bin + /usr/local/share  (system-wide, requires sudo)"
echo " 1) ~/.local/bin + ~/.local/share      (current user only)"

choice=""
ask choice "Choose installation target (0 or 1)"
if [ "$choice" != "0" ] && [ "$choice" != "1" ]; then
  error "Invalid choice: '$choice'"
  exit 1
fi

step 7 $TOTAL
if [ "$choice" = "0" ]; then
  info "Preparing system-wide directories"
  run sudo mkdir -p /usr/local/share/tb2
  run sudo mkdir -p /usr/local/bin
  SHARE_DIR="/usr/local/share/tb2"
  BIN_DIR="/usr/local/bin"
  USE_SUDO="sudo"
else
  info "Preparing user directories"
  run mkdir -p ~/.local/share/tb2
  run mkdir -p ~/.local/bin
  SHARE_DIR="$HOME/.local/share/tb2"
  BIN_DIR="$HOME/.local/bin"
  USE_SUDO=""
fi

step 8 $TOTAL
info "Copying tb2 files"
if [ "$choice" = "0" ]; then
  run sudo cp -r ./* "$SHARE_DIR/"
else
  run cp -r ./* "$SHARE_DIR/"
fi

step 9 $TOTAL
info "Setting permissions..."
if [ "$choice" = "0" ]; then
  run sudo chmod -R a+rx "$SHARE_DIR"
else
  run chmod -R u+rx "$SHARE_DIR"
fi

step 10 $TOTAL
info "Creating symlink"
if [ "$choice" = "0" ]; then
  run sudo ln -sf "$SHARE_DIR/script/tb2" "$BIN_DIR/tb2"
else
  run ln -sf "$SHARE_DIR/script/tb2" "$BIN_DIR/tb2"
fi

step 11 $TOTAL
info "Verifying installation..."
if ! command -v tb2 >/dev/null 2>&1; then
  warn "tb2 is not in PATH yet."
  if [ "$choice" = "1" ]; then
    warn "Make sure '$BIN_DIR' is in your PATH."
    warn "Add the following to your shell config (~/.bashrc, ~/.zshrc, etc.):"
    printf "%b" "  ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}\n"
  fi
else
  info "tb2 successfully installed at: $(command -v tb2)"
fi

log ""
log "Installation complete."
log "Run 'tb2 --help' to get started."
exit 0