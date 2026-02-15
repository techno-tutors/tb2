#!/usr/bin/env bash
set -euo pipefail

#shellcheck source=script/utils.sh
. "$ROOT/utils.sh"
#shellcheck source=script/interactive/funcs.sh
. "$ROOT/interactive/funcs.sh"

info "Entering interactive mode. Type 'exit' to quit."
log "#--------------------------------#"
log "#    TB2: TextBook ToolBox       #"
log "#--------------------------------#"
info "type help to see available commands."
if gh_isManualMode; then
  warn "interactive mode is disabled when we are in manual mode"
fi
while true; do
  cmd=""
  ask cmd "tb2?" | xargs
  [ -z "$cmd" ] && continue
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
      if [ -x "$ROOT/tb2" ]; then
        run "$ROOT/tb2" "$cmd"
      else
        warn "Unknown command: $cmd"
      fi
      ;;
  esac
done
exit 0
