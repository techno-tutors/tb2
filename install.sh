#!/usr/bin/env bash
set -euo pipefail

ESC="\033["
RESET="${ESC}0m"
BOLD="${ESC}1m"
BLUE="${ESC}34m"
YELLOW="${ESC}33m"
RED="${ESC}31m"
GREEN="${ESC}32m"

log()   { printf "%b" "[+] $1\n"; }
info()  { printf "%b" "${BLUE}${BOLD}[*]${RESET} $1\n"; }
warn()  { printf "%b" "${YELLOW}${BOLD}[!]${RESET} $1\n"; }
error() { printf "%b" "${RED}${BOLD}[-]${RESET} $1\n"; }
success(){ printf "%b" "${GREEN}${BOLD}[✓]${RESET} $1\n"; }

ask() {
  local __var="$1"; shift
  printf "%b" "${BOLD}${GREEN}[?]${RESET} $*\n ${BOLD}${GREEN}>>${RESET} "
  if ! read -r answer </dev/tty; then
    error "No interactive input available."
    exit 1
  fi
  eval "$__var=\"\$answer\""
}

step() { printf "%b" "${BLUE}${BOLD}-----[ step $1/$2 ]----------------------------------------${RESET}\n"; }

REPO_URL="https://github.com/techno-tutors/tb2.git"
TOTAL=9

step 1 $TOTAL
info "Checking required dependencies..."
MISSING=()
for cmd in git bash; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    MISSING+=("$cmd")
  fi
done
if [ ${#MISSING[@]} -gt 0 ]; then
  error "Missing required commands: ${MISSING[*]}"
  exit 1
fi
success "All required dependencies found."

step 2 $TOTAL
echo " 0) /usr/local/bin + /usr/local/share  (system-wide, requires sudo)"
echo " 1) ~/.local/bin   + ~/.local/share    (current user only)"

choice=""
ask choice "Choose installation target (0 or 1)"
if [ "$choice" != "0" ] && [ "$choice" != "1" ]; then
  error "Invalid choice: '$choice'"
  exit 1
fi

if [ "$choice" = "0" ]; then
  SHARE_DIR="/usr/local/share/tb2"
  BIN_DIR="/usr/local/bin"
  USE_SUDO="sudo"
else
  SHARE_DIR="$HOME/.local/share/tb2"
  BIN_DIR="$HOME/.local/bin"
  USE_SUDO=""
fi
info "Installing to: $SHARE_DIR"

step 3 $TOTAL
if [ -d "$SHARE_DIR" ]; then
  warn "Existing installation found at $SHARE_DIR."
  ans=""
  ask ans "Overwrite? (y/n)"
  if [ "$ans" != "y" ] && [ "$ans" != "Y" ]; then
    info "Aborted."
    exit 0
  fi
  if [ -n "$USE_SUDO" ]; then
    sudo rm -rf "$SHARE_DIR"
  else
    rm -rf "$SHARE_DIR"
  fi
  success "Old installation removed."
fi

step 4 $TOTAL
info "Cloning tb2 from $REPO_URL..."
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

git clone --depth=1 "$REPO_URL" "$TMP_DIR/tb2"
success "Clone complete."

step 5 $TOTAL
info "Creating directories..."
if [ -n "$USE_SUDO" ]; then
  sudo mkdir -p "$SHARE_DIR" "$BIN_DIR"
else
  mkdir -p "$SHARE_DIR" "$BIN_DIR"
fi

step 6 $TOTAL
info "Copying files to $SHARE_DIR..."
if [ -n "$USE_SUDO" ]; then
  sudo cp -r "$TMP_DIR/tb2/." "$SHARE_DIR/"
else
  cp -r "$TMP_DIR/tb2/." "$SHARE_DIR/"
fi
success "Files copied."

step 7 $TOTAL
info "Setting permissions..."
if [ -n "$USE_SUDO" ]; then
  sudo find "$SHARE_DIR/script" -type f -exec chmod 755 {} \;
  sudo chmod -R a+rX "$SHARE_DIR"
else
  find "$SHARE_DIR/script" -type f -exec chmod 755 {} \;
  chmod -R u+rX "$SHARE_DIR"
fi
success "Permissions set."

step 8 $TOTAL
info "Creating symlink: $BIN_DIR/tb2 -> $SHARE_DIR/script/tb2"
if [ -n "$USE_SUDO" ]; then
  sudo ln -sf "$SHARE_DIR/script/tb2" "$BIN_DIR/tb2"
  echo "SHARE_DIR=$SHARE_DIR" | sudo tee "$SHARE_DIR/.tb2meta" >/dev/null
  echo "BIN_DIR=$BIN_DIR"     | sudo tee -a "$SHARE_DIR/.tb2meta" >/dev/null
else
  ln -sf "$SHARE_DIR/script/tb2" "$BIN_DIR/tb2"
  printf "SHARE_DIR=%s\nBIN_DIR=%s\n" "$SHARE_DIR" "$BIN_DIR" > "$SHARE_DIR/.tb2meta"
fi
success "Symlink created."

step 9 $TOTAL
if command -v tb2 >/dev/null 2>&1; then
  success "tb2 successfully installed at: $(command -v tb2)"
else
  warn "tb2 is not in PATH yet."
  if [ "$choice" = "1" ]; then
    warn "Add the following to your shell config (~/.bashrc, ~/.zshrc, etc.):"
    printf "  %b\n" "${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
  fi
fi

echo
success "Installation complete! Run 'tb2 --help' to get started."
exit 0