#!/usr/bin/env bash
set -euo pipefail

ESC="\033["
RESET="${ESC}0m"
BOLD="${ESC}1m"
BLUE="${ESC}34m"
YELLOW="${ESC}33m"
RED="${ESC}31m"
GREEN="${ESC}32m"

log()     { printf "%b" "[+] $1\n"; }
info()    { printf "%b" "${BLUE}${BOLD}[*]${RESET} $1\n"; }
warn()    { printf "%b" "${YELLOW}${BOLD}[!]${RESET} $1\n"; }
error()   { printf "%b" "${RED}${BOLD}[-]${RESET} $1\n"; }
success() { printf "%b" "${GREEN}${BOLD}[✓]${RESET} $1\n"; }

ask() {
  local __var="$1"
  shift
  printf "%b" "${BOLD}${GREEN}[?]${RESET} $*\n ${BOLD}${GREEN}>>${RESET} "
  if ! read -r answer </dev/tty; then
    error "No interactive input available."
    exit 1
  fi
  eval "$__var=\"\$answer\""
}

catch() {
  if [ "$1" -ne 0 ]; then
    error "Command failed with exit code $1."
    return 2
  fi
  return 0
}

run() {
  log "Running> $*"
  trap 'set -e' EXIT
  set +e
  "$@"
  local status=$?
  set -e
  catch "$status"
  return "$status"
}

tb2_findRoot() {
  local dir
  dir="$(pwd)"
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/book.toml" ]; then
      echo "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

tb2_findScriptRoot() {
  local self
  self="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || realpath "${BASH_SOURCE[0]}" 2>/dev/null || echo "${BASH_SOURCE[0]}")"
  echo "$(dirname "$self")"
}

useConf() {
  local key="$1"
  local __resultvar="$2"
  local val
  val=$("$ROOT/subcmds/config.d/config" get "$key" 2>/dev/null || true)
  if [ -z "$val" ]; then
    error "Config '$key' is not set."
    echo "Run: tb2 config set $key <value>"
    exit 1
  fi
  eval "$__resultvar=\"\$val\""
}

tb2_isManualMode() {
  local mode
  useConf GH_CLI_MODE mode
  [ "$mode" = "manual" ]
}

gh_chkAvailable() {
  if tb2_isManualMode; then
    return 0
  fi
  if ! command -v gh >/dev/null 2>&1; then
    warn "GitHub CLI (gh) is not installed. See https://cli.github.com/"
    return 1
  fi
  if ! gh auth status >/dev/null 2>&1; then
    warn "Not logged in to GitHub CLI. Run 'gh auth login' first."
    return 1
  fi
  return 0
}

mdbook_chkAvailable() {
  if ! command -v mdbook >/dev/null 2>&1; then
    warn "mdBook is not installed. See https://github.com/rust-lang/mdBook"
    return 1
  fi
  local projectRoot
  if ! projectRoot="$(tb2_findRoot)"; then
    warn "No mdBook project found (book.toml not found in current or parent directories)."
    return 1
  fi
  export TB2_PROJECT_ROOT="$projectRoot"
  useConf MDBOOK_SRC_DIR srcdir
  if [ -z "$srcdir" ]; then
    srcdir="src"
  fi
  if [ ! -d "$projectRoot/$srcdir" ]; then
    warn "mdBook '$srcdir' directory not found in '$projectRoot'."
    return 1
  fi
  return 0
}

gh_createIssue() {
  local repo="$1"
  local title="$2"
  local body="$3"
  local label="${4:-}"

  if tb2_isManualMode; then
    info "[MANUAL] Create the following GitHub Issue:"
    echo "  Repo:  $repo"
    echo "  Title: $title"
    echo "  Body:  $body"
    [ -n "$label" ] && echo "  Label: $label"
    return 0
  fi

  local args=(gh issue create --repo "$repo" --title "$title" --body "$body")
  [ -n "$label" ] && args+=(--label "$label")
  run "${args[@]}"
}

gh_createPR() {
  local repo="$1"
  local base="$2"
  local head="$3"
  local title="$4"
  local body="$5"

  if tb2_isManualMode; then
    info "[MANUAL] Create the following Pull Request:"
    echo "  Repo: $repo"
    echo "  Base: $base  <--  Head: $head"
    echo "  Title: $title"
    echo "  Body:  $body"
    return 0
  fi

  if gh pr list --repo "$repo" --head "$head" --base "$base" --json number --jq '.[0].number' 2>/dev/null | grep -q '^[0-9]'; then
    warn "PR from '$head' to '$base' already exists. Skipping."
    return 0
  fi

  run gh pr create --repo "$repo" --base "$base" --head "$head" --title "$title" --body "$body"
}

gh_findIssue() {
  local repo="$1"
  local search="$2"
  local state="${3:-open}"

  if tb2_isManualMode; then
    warn "[MANUAL] Search for issues manually:"
    echo "  Repo: $repo  Query: $search  State: $state"
    return 1
  fi

  gh issue list --repo "$repo" --search "$search" --state "$state" \
    --json number,title,state \
    --jq '.[] | "#\(.number) [\(.state)] \(.title)"'
}

gh_closeIssue() {
  local repo="$1"
  local number="$2"
  local comment="${3:-}"

  if tb2_isManualMode; then
    info "[MANUAL] Close Issue #$number in $repo"
    [ -n "$comment" ] && echo "  Comment: $comment"
    return 0
  fi

  if [ -n "$comment" ]; then
    run gh issue comment "$number" --repo "$repo" --body "$comment"
  fi
  run gh issue close "$number" --repo "$repo"
}

gh_getIssueNumber() {
  local repo="$1"
  local title_pattern="$2"

  if tb2_isManualMode; then
    echo ""
    return 0
  fi

  gh issue list --repo "$repo" --search "$title_pattern" --json number \
    --jq '.[0].number' 2>/dev/null || echo ""
}

git_chkBranch() {
  local branch="$1"

  if tb2_isManualMode; then
    info "[MANUAL] Switch to branch '$branch' manually:"
    echo "  git switch $branch"
    echo "  (or: git switch -c $branch)"
    return 0
  fi

  local current
  current="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")"

  if [ "$current" = "$branch" ]; then
    log "Already on branch '$branch'."
    return 0
  fi

  if git show-ref --verify --quiet "refs/heads/$branch"; then
    log "Switching to existing branch '$branch'..."
    run git switch "$branch"
  else
    ans=""
    ask ans "Branch '$branch' not found. Create it? [c=create / e=exit]"
    if [ "$ans" = "c" ] || [ "$ans" = "C" ]; then
      run git switch -c "$branch"
    else
      info "Aborted."
      exit 0
    fi
  fi
}

tb2_applyTemplate() {
  local templateType="$1"
  local outFile="$2"
  local bookName="${3:-}"
  local chapterName="${4:-}"
  local pageName="${5:-}"

  local templateFile="$ROOT/subcmds/config.d/templates/$templateType.md"
  local today
  today="$(date +%Y-%m-%d)"

  if [ ! -f "$templateFile" ]; then
    touch "$outFile"
    return 0
  fi

  sed \
    -e "s/{{BOOK_NAME}}/$bookName/g" \
    -e "s/{{CHAPTER_NAME}}/$chapterName/g" \
    -e "s/{{PAGE_NAME}}/$pageName/g" \
    -e "s/{{DATE}}/$today/g" \
    "$templateFile" > "$outFile"

  log "Template applied to $outFile"
}

tb2_getEditor() {
  local editor="${TB2_EDITOR:-${VISUAL:-${EDITOR:-}}}"
  if [ -z "$editor" ]; then
    for e in nvim vim nano vi; do
      if command -v "$e" >/dev/null 2>&1; then
        editor="$e"
        break
      fi
    done
  fi
  echo "$editor"
}