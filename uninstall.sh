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
	read -r answer
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
  "$@"
  catch $?
  set -e
  return $?
}

step() {
  printf "%b" "${BLUE}${BOLD}-----[ step $1/$2 ]----------------------------------------${RESET}\n"
}

TOTAL=4

step 1 $TOTAL
info "Choose uninstall target"
echo " 0) System-wide (/usr/local)"
echo " 1) User install (~/.local)"
ask choice "Select 0 or 1"
if [ "$choice" != "0" ] && [ "$choice" != "1" ]; then
  error "Invalid choice"
  exit 1
fi

step 2 $TOTAL
if [ "$choice" = "0" ]; then
  info "Removing system-wide files"
  run sudo rm -f /usr/local/bin/tb2
  run sudo rm -rf /usr/local/share/tb2
else
  info "Removing user files"
  run rm -f ~/.local/bin/tb2
  run rm -rf ~/.local/share/tb2
fi

step 3 $TOTAL
info "Checking for leftover files"
if command -v tb2 >/dev/null 2>&1; then
  warn "tb2 still exists in PATH"
else
  log "tb2 removed from PATH"
fi

step 4 $TOTAL
log "Uninstallation complete."
exit 0
