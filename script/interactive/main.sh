#!/usr/bin/env bash
set -euo pipefail

base_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/.."
#shellcheck source=script/utils.sh
source "$base_dir/utils.sh"
#shellcheck source=script/interactive/funcs.sh
source "$base_dir/interactive/funcs.sh"

info "Entering interactive mode. Type 'exit' to quit."
log "#--------------------------------#"
log "#    TB2: TextBook ToolBox       #"
log "#--------------------------------#"
info "type help to see available commands."

while true; do
  cmd=$(ask "tb2?" | xargs)
  [[ -z "$cmd" ]] && continue
  case "$cmd" in
  "exit" | "quit")
    info "Exiting interactive mode."
    break
    ;;
  "help")
    show_help
    ;;
  "book")
    interactive_book
    ;;
  "chapter")
    interactive_chapter
    ;;
  "page")
    interactive_page
    ;;
  "project")
    interactive_project
    ;;
  *)
    if [[ -x "$base_dir/tb2" ]]; then
      run "$base_dir/tb2 $cmd"
    else
      warn "Unknown command: $cmd"
    fi
    ;;
  esac
done
exit 0
