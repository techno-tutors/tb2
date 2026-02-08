#!/usr/bin/env bash
set -euo pipefail

#shellcheck source=script/utils.sh
. "$ROOT/utils.sh"

show_help() {
  info "tb2 - TextBook ToolBox (Interactive Mode)"
  log "GitHub automation & textbook builder CLI"
  echo

  info "Available commands:"
  log "  book     - Manage books"
  log "  chapter  - Manage chapters"
  log "  page     - Manage pages"
  log "  project  - View project structure"
  log "  help     - Show this help"
  log "  exit     - Quit interactive mode"
  log "  quit     - same as exit"
  echo
}

interactive_book() {
  info "Book commands:"
  log "  1) new  - Create new book"
  log "  2) list - List books"

  sub=$(ask "book")
  case "$sub" in
    "1" | "new")
      name=$(ask "Book name")
      "$ROOT/tb2" book new -b "$name"
      ;;
    "2" | "list")
      "$ROOT/tb2" book list
      ;;
    *)
      warn "Unknown book subcommand."
      ;;
  esac
}

interactive_chapter() {
  info "Chapter commands:"
  log "  1) new  - Create new chapter"
  log "  2) save - Save chapter (PR)"
  log "  3) list - List chapters"

  sub=$(ask "chapter")
  case "$sub" in
    "1" | "new")
      book=$(ask "Book name")
      chapter=$(ask "Chapter name")
      "$ROOT/tb2" chapter new -b "$book" -c "$chapter"
      ;;
    "2" | "save")
      book=$(ask "Book name")
      chapter=$(ask "Chapter name")
      "$ROOT/tb2" chapter save -b "$book" -c "$chapter"
      ;;
    "3" | "list")
      book=$(ask "Book name")
      "$ROOT/tb2" chapter list -b "$book"
      ;;
    *)
      warn "Unknown chapter subcommand."
      ;;
  esac
}

interactive_page() {
  info "Page commands:"
  log "  1) new  - Create new page"
  log "  2) save - Save page"
  log "  3) list - List pages"

  sub=$(ask "page")
  case "$sub" in
    "1" | "new")
      book=$(ask "Book name")
      chapter=$(ask "Chapter name")
      page=$(ask "Page name? (empty for auto)")
      if [ -z "$page" ]; then
        "$ROOT/tb2" page new -b "$book" -c "$chapter"
      else
        "$ROOT/tb2" page new -b "$book" -c "$chapter" -p "$page"
      fi
      ;;
    "2" | "save")
      book=$(ask "Book name")
      chapter=$(ask "Chapter name")
      page=$(ask "Page name")
      "$ROOT/tb2" page save -b "$book" -c "$chapter" -p "$page"
      ;;
    "3" | "list")
      book=$(ask "Book name")
      chapter=$(ask "Chapter name")
      "$ROOT/tb2" page list -b "$book" -c "$chapter"
      ;;
    *)
      warn "Unknown page subcommand."
      ;;
  esac
}

interactive_project() {
  info "Project view commands:"
  log "  1) list - Show books and chapters"
  log "  2) list with pages"

  sub=$(ask "project")
  case "$sub" in
    "1" | "list")
      "$ROOT/tb2" project list
      ;;
    "2" | "pages")
      "$ROOT/tb2" project list -p
      ;;
    *)
      warn "Unknown project subcommand."
      ;;
  esac
}
