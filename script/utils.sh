#!/usr/bin/env bash
set -euo pipefail

ESC="\033["
RESET="${ESC}0m"
BOLD="${ESC}1m"
BLUE="${ESC}34m"
YELLOW="${ESC}33m"
RED="${ESC}31m"
GREEN="${ESC}32m"

function log(){
  printf "%b" "[+] $1\n"
}
function info(){
  printf "%b" "${BLUE}${BOLD}[*]${RESET} $1 \n"
}
function warn(){
  printf "%b" "${YELLOW}${BOLD}[!]${RESET} $1 \n"
}
function error(){
  printf "%b" "${RED}${BOLD}[-]${RESET} $1"
}
function ask(){
  read -p "$(printf "%b" "${BOLD}${GREEN}[?]${RESET}$1\n\t${BOLD}${GREEN}>>${RESET}")" answer
  echo "$answer"
}
function catch(){
  if [[ $? -ne 0 ]]; then
    error "Command failed with exit code $?."
  else 
    info "Command executed successfully."
  fi
}
function run(){
  info "Runnning> $*"
  "$@"||catch
}
function gh.chkAvailable() {
  # Check if gh is installed
  info "Checking GitHub CLI availability..."
  if ! command -v gh >/dev/null 2>&1; then
    warn "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/ or your package manager.\n"
    return 1
  fi
  # Check if user is logged in
  info "Checking GitHub CLI user auth status..."
  if ! gh auth status >/dev/null 2>&1; then
    warn "You are not logged in to GitHub CLI. Please run 'gh auth login' first.\n"
    return 1
  fi
  return 0
}
function mdbook.chkAvailable() {
  # Check if mdbook is installed
  info "Checking mdBook availability..."
  if ! command -v mdbook >/dev/null 2>&1; then
    warn "mdBook is not installed. Please install it from https://github.com/rust-lang/mdBook or your package manager.\n"
    return 1
  fi
  # Check if we are in an mdBook project directory
  info "Checking if current directory is an mdBook project..."
  if [[ ! -f book.toml ]]; then
    warn "This directory is not root of mdBook project. Please run this command in the root directory of your mdBook project.\n"
    return 1
  fi
  # Check src directory exists
  info "Checking mdBook 'src' directory existence..."
  info "Lookig for default source directory config"
  srcdir=""
  run "srcdir=$base_dir/tb2" config --get 'MDBOOK_SRCDIR' >/dev/null 2>&1
  if [[ -z "$srcdir" ]]; then
    info "No custom source directory configured. Using default 'src'."
    srcdir="src"
  else
    info "Using configured source directory: '$srcdir'"
  fi
  if [[ ! -d "$srcdir" ]]; then
    warn "mdBook '$srcdir' directory not found. Please ensure you are in a valid mdBook project directory.\n"
    return 1
  fi
  return 0
}