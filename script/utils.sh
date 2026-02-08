#!/usr/bin/env bash
# shellcheck disable=SC2154
set -euo pipefail

ESC="\033["
RESET="${ESC}0m"
BOLD="${ESC}1m"
BLUE="${ESC}34m"
YELLOW="${ESC}33m"
RED="${ESC}31m"
GREEN="${ESC}32m"

log() {
  printf "%b" "[+] $1\n"
}
info() {
  printf "%b" "${BLUE}${BOLD}[*]${RESET} $1 \n"
}
warn() {
  printf "%b" "${YELLOW}${BOLD}[!]${RESET} $1 \n"
}
error() {
  printf "%b" "${RED}${BOLD}[-]${RESET} $1 \n"
}
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
  "$@"
  catch $?
  set -e
  return $?
}
useConf() {
  local key="$1"
  local __resultvar="$2"

  local val
  val=$("$ROOT/subcmds/config.d/config" get "$key" 2> /dev/null || true)

  if [ -z "$val" ]; then
    error "Config '$key' is not set."
    echo "Run: tb2 config set $key <value>"
    exit 1
  fi

  eval "$__resultvar=\"\$val\""
}
gh_isManualMode() {
  useConf GH_CLI_MODE mode
  if [ "$mode" = "manual" ]; then
    return 0
  fi
  return 1
}
gh_chkAvailable() {
  if gh_isManualMode; then
    return 0
  fi
  # Check if gh is installed
  info "Checking GitHub CLI availability..."
  if ! command -v gh > /dev/null 2>&1; then
    warn "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/ or your package manager."
    return 1
  fi
  # Check if user is logged in
  info "Checking GitHub CLI user auth status..."
  if ! gh auth status > /dev/null 2>&1; then
    warn "You are not logged in to GitHub CLI. Please run 'gh auth login' first."
    return 1
  fi
  return 0
}
mdbook_chkAvailable() {
  # Check if mdbook is installed
  info "Checking mdBook availability..."
  if ! command -v mdbook > /dev/null 2>&1; then
    warn "mdBook is not installed. Please install it from https://github.com/rust-lang/mdBook or your package manager."
    return 1
  fi
  # Check if we are in an mdBook project directory
  info "Checking if current directory is an mdBook project..."
  log "checking for book.toml file..."
  if [ ! -f book.toml ]; then
    warn "This directory is not root of mdBook project. Please run this command in the root directory of your mdBook project."
    return 1
  fi
  # Check src directory exists
  info "Checking mdBook 'src' directory existence..."
  info "Looking for default source directory config"

  useConf MDBOOK_SRC_DIR srcdir
  if [ -z "$srcdir" ]; then
    info "No custom source directory configured. Using default 'src'."
    srcdir="src"
  else
    info "Using configured source directory: '$srcdir'"
  fi
  if [ ! -d "$srcdir" ]; then
    warn "mdBook '$srcdir' directory not found. Please ensure you are in a valid mdBook project directory."
    return 1
  fi
  info "mdBook project directory confirmed."
  return 0
}
gh_createIssue() {
  local repo="$1"
  local title="$2"
  local body="$3"

  if gh_isManualMode; then
    info "GitHub CLI manual mode is enabled."
    echo
    info "Please create the following GitHub Issue manually:"
    echo "--------------------------------------------"
    echo "Repository: $repo"
    echo "Title: $title"
    echo "Body:"
    echo "$body"
    echo "--------------------------------------------"
    return 0
  fi

  run gh issue create --repo "$repo" --title "$title" --body "$body"
}
gh_createPR() {
  local repo="$1"
  local base="$2"
  local head="$3"
  local title="$4"
  local body="$5"

  if gh_isManualMode; then
    info "GitHub CLI manual mode is enabled."
    echo
    info "Please create the following Pull Request manually:"
    echo "--------------------------------------------"
    echo "Repository: $repo"
    echo "Base branch: $base"
    echo "Head branch: $head"
    echo "Title: $title"
    echo "Body:"
    echo "$body"
    echo "--------------------------------------------"
    return 0
  fi

  run gh pr create --repo "$repo" --base "$base" --head "$head" --title "$title" --body "$body"
}
gh_findIssue() {
  local repo="$1"
  local search="$2"

  if gh_isManualMode; then
    warn "Manual mode: cannot auto-search GitHub issues."
    echo ""
    echo "Please find issue manually in repository:"
    echo "Repo: $repo"
    echo "Search query: $search"
    echo ""
    return 1
  fi

  gh issue list --repo "$repo" --search "$search" --json number,title \
    --jq '.[] | "\(.number): \(.title)"'
}
s_gitCommit() {
  local msg="$1"

  if [ -z "$(git status --porcelain)" ]; then
    info "Nothing to commit."
    return
  fi

  git add .
  git commit -m "$msg"

  current=$(git branch --show-current)
  info "Pushing branch: $current"

  git push origin "$current"
}
git_chkBranch() {
  local branch=$1
  log "Using branch: $branch"
  log "Checking if exist of branch name..."
  if [ "$(git rev-parse --abbrev-ref HEAD 2> /dev/null || echo)" != "$branch" ]; then
    log "Branch '$branch' is not current branch."
    log "Checking for branch existence..."
    if git show-ref --verify --quiet "refs/heads/$branch"; then
      log "Branch '$branch' exists."
    else
      log "Branch '$branch' does not exist."
      ans=""
      ask ans "Create branch[c] or Exit[e]?"
      if [ "$ans" = "c" ] || [ "$ans" = "C" ]; then
        run git switch -c "$branch"
        log "done."
      else
        info "Exit."
        exit 0
      fi
    fi
    log "Switching to branch '$branch'..."
    run git switch "$branch"
    log "done."
  else
    log "Already on branch '$branch'."
    log "done."
  fi
}
