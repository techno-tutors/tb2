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
function run(){
  info "Run: $*"
  "$@"
}