#!/usr/bin/env bash
set -euo pipefail

ESC=$'\e['
YELLOW="33m"
RED="31m"
GREEN="32m"
BLUE="34m"
BOLD="1m"
RESET="0m"

function log(){
  printf "[+] %s\n" "$1"
}
function info(){
  printf "${ESC}${BLUE}[*]${ESC}${RESET} %s\n" "$1"
}
function warn(){
  printf "${ESC}${YELLOW}[!]${ESC}${RESET} %s\n" "$1"
}
function error(){
  printf "${ESC}${RED}[-]${ESC}${RESET} %s\n" "$1"
}
function ask(){
  read -p "$(printf "${ESC}${BOLD}${ESC}${GREEN}[?]${ESC}${RESET} %s\n\t${ESC}${BOLD}${ESC}${GREEN}>>${ESC}${RESET}" "$1")" answer
  echo "$answer"
}
function run(){
  info "Run: $*"
  "$@"
}