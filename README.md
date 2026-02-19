# tb2

A command-line toolbox for textbook management using GitHub Issues and mdBook.
TB2 automates the creation and management of educational content through a three-level Issue hierarchy, and works from any directory inside an mdBook project.

**TextBook ToolBox === TB2**

---

## Table of Contents

- [About](#about)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Project Detection](#project-detection)
- [Usage](#usage)
  - [config](#config)
  - [book](#book)
  - [chapter](#chapter)
  - [page](#page)
  - [project](#project)
  - [status](#status)
  - [Interactive Mode](#interactive-mode)
- [Templates](#templates)
- [Manual Mode](#manual-mode)
- [GitHub Integration](#github-integration)
- [Update / Uninstall](#update--uninstall)
- [Complete Workflow](#complete-workflow)
- [Contributing](#contributing)
- [License](#license)

---

## About

TB2 integrates GitHub Issues with mdBook projects:

- Hierarchical Issue management: Book → Chapter → Page
- Automatic branch creation and pull request workflows
- CLI and interactive modes
- Template system for new content
- Project-root auto-detection (run from any subdirectory)
- Manual mode for environments without GitHub CLI

### Issue Hierarchy

```
Series (GitHub Project, optional)
│
Book   (GitHub Issue:  "Book: NAME")
└── Chapter (GitHub Issue: "Chapter: NAME (BOOK)" + branch chapter/NAME)
    └── Page (GitHub Issue: "Page: NAME (CHAPTER)" + .md file)
```

---

## Prerequisites

| Tool | Required | Notes |
|------|----------|-------|
| bash ≥ 4.0 | Yes | |
| git | Yes | |
| mdBook | Yes | https://github.com/rust-lang/mdBook |
| GitHub CLI (gh) | No | Required unless `GH_CLI_MODE=manual`. https://cli.github.com/ |

---

## Installation

### curl

```sh
curl -fsSL https://raw.githubusercontent.com/techno-tutors/tb2/main/install.sh | bash
```

### wget

```sh
wget -qO- https://raw.githubusercontent.com/techno-tutors/tb2/main/install.sh | bash
```

The installer will ask whether to install system-wide (`/usr/local`) or for the current user only (`~/.local`). The user install is recommended.

If `~/.local/bin` is not in your PATH, add this to `~/.bashrc` or `~/.zshrc`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

---

## Configuration

```sh
tb2 config set GH_OWNER_NAME  "your-github-username-or-org"
tb2 config set GH_REPO_NAME   "your-repository-name"
tb2 config set MDBOOK_SRC_DIR "src"
tb2 config set TB2_OPERATION_BRANCH "draft"
tb2 config set GH_CLI_MODE    "auto"   # or "manual"
```

### View all settings

```sh
tb2 config list
```

### Get a single value

```sh
tb2 config get GH_OWNER_NAME
```

### Configuration Keys

| Key | Description | Default |
|-----|-------------|---------|
| `GH_OWNER_NAME` | GitHub username or organization | `techno-tutors` |
| `GH_REPO_NAME` | GitHub repository name | `textbook` |
| `MDBOOK_SRC_DIR` | mdBook source directory | `src` |
| `TB2_OPERATION_BRANCH` | Base branch for operations | `draft` |
| `GH_CLI_MODE` | `auto` (use gh CLI) or `manual` | `auto` |

---

## Project Detection

tb2 automatically finds your mdBook project root by walking up the directory tree looking for `book.toml`. This means you can run tb2 from any subdirectory of your project:

```sh
cd src/Cryptography/RSA
tb2 page list -b Cryptography -c RSA   # works fine
```

---

## Usage

### config

```sh
tb2 config list
tb2 config get KEY
tb2 config set KEY VALUE
```

---

### book

#### Create a new book

```sh
tb2 book new -b BOOKNAME [-a] [-t]
```

| Flag | Description |
|------|-------------|
| `-b` | Book name (required) |
| `-a` | Auto commit and push without prompt |
| `-t` | Apply book template to `README.md` |

```sh
tb2 book new -b Cryptography -t
```

#### List books

```sh
tb2 book list
```

Shows remote GitHub Issues and local directories.

#### Build

```sh
tb2 book build [-b BOOKNAME] [--open] [--dest DIR]
```

Wraps `mdbook build`. `--open` launches the browser after build.

#### Serve

```sh
tb2 book serve [--port PORT] [--hostname HOST] [--open]
```

Wraps `mdbook serve`.

---

### chapter

#### Create a new chapter

```sh
tb2 chapter new -b BOOKNAME -c CHAPTERNAME [-n ISSUE_NUM] [-a] [-t]
```

| Flag | Description |
|------|-------------|
| `-b` | Book name (required) |
| `-c` | Chapter name (required) |
| `-n` | Parent Book Issue number (required in manual mode) |
| `-a` | Auto commit and push |
| `-t` | Apply chapter template to `intro.md` |

Creates branch `chapter/CHAPTERNAME` and a GitHub Issue linked to the parent Book Issue.

#### Save chapter (create pull request)

```sh
tb2 chapter save -b BOOKNAME -c CHAPTERNAME [--close-issue]
```

Creates a PR from `chapter/CHAPTERNAME` → `TB2_OPERATION_BRANCH`. If a PR already exists, the command skips creation. `--close-issue` closes the Chapter Issue after PR creation.

#### List chapters

```sh
tb2 chapter list -b BOOKNAME
```

---

### page

#### Create a new page

```sh
tb2 page new -b BOOKNAME -c CHAPTERNAME [-p PAGENAME] [-n ISSUE_NUM] [-t]
```

| Flag | Description |
|------|-------------|
| `-b` | Book name (required) |
| `-c` | Chapter name (required) |
| `-p` | Page name without `.md` (auto-numbered `p1`, `p2`... if omitted) |
| `-n` | Parent Chapter Issue number (required in manual mode) |
| `-t` | Apply page template |

#### Edit a page

```sh
tb2 page edit -b BOOKNAME -c CHAPTERNAME -p PAGENAME
```

Opens the page in your preferred editor. Editor resolution order: `$TB2_EDITOR` → `$VISUAL` → `$EDITOR` → first of `nvim`, `vim`, `nano`, `vi` found in PATH.

If the page does not exist, you are prompted to create it (with template if configured).

```sh
TB2_EDITOR=code tb2 page edit -b Cryptography -c RSA -p Introduction
```

#### Save a page

```sh
tb2 page save -b BOOKNAME -c CHAPTERNAME -p PAGENAME [-a]
```

Commits and pushes the page file to the current chapter branch. `-a` skips the confirmation prompt.

#### List pages

```sh
tb2 page list -b BOOKNAME -c CHAPTERNAME
```

Shows remote Issues and local `.md` files with line and byte counts.

---

### project

```sh
tb2 project list [-p]
```

`-p` includes pages in the output.

```
=Local [mdBook project]=
========================================
[bok] Cryptography
  [chap] RSA
    [pag] Introduction
    [pag] KeyGeneration
  [chap] EllipticCurves
    [pag] Overview
========================================
```

---

### status

```sh
tb2 status [-b BOOKNAME] [--remote]
```

Reports:
- Page counts per book and chapter
- Empty or stub pages (0 bytes or fewer than 3 lines)
- Books missing a `README.md` / `intro.md` / `index.md`
- Empty chapter directories (no `.md` files)
- With `--remote`: open GitHub Issues and open Pull Requests

```sh
tb2 status
tb2 status -b Cryptography
tb2 status --remote
```

---

### Interactive Mode

```sh
tb2
# or
tb2 -i
```

Numbered menus guide you through all operations. Available commands in interactive mode:

```
book      chapter      page      project
status    update       uninstall help      exit
```

---

## Templates

Templates are stored in `script/subcmds/config.d/templates/`. Edit them to match your project style.

| File | Used by |
|------|---------|
| `book.md` | `tb2 book new -t` → `README.md` |
| `chapter.md` | `tb2 chapter new -t` → `intro.md` |
| `page.md` | `tb2 page new -t` or `tb2 page edit` (new file) |

Available template variables:

| Variable | Value |
|----------|-------|
| `{{BOOK_NAME}}` | Book name |
| `{{CHAPTER_NAME}}` | Chapter name |
| `{{PAGE_NAME}}` | Page name |
| `{{DATE}}` | Current date (`YYYY-MM-DD`) |

---

## Manual Mode

For environments without GitHub CLI, or if you prefer manual control:

```sh
tb2 config set GH_CLI_MODE "manual"
```

In manual mode, all GitHub operations (Issue creation, PR creation, branch operations via `gh`) are replaced with printed instructions. Local file and git operations continue to work.

```
[MANUAL] Create the following GitHub Issue:
  Repo:  your-org/textbook
  Title: Chapter: RSA (Cryptography)
  Body:  Chapter 'RSA' in book 'Cryptography'. Parent: #3
```

Commands that require `-n` (Issue number) become mandatory in manual mode, because automatic Issue lookup via `gh` is disabled.

---

## GitHub Integration

tb2 uses `gh` for:

| Action | Command triggered |
|--------|-----------------|
| Create Issue (book/chapter/page) | `gh issue create` |
| Create Pull Request | `gh pr create` |
| List Issues | `gh issue list` |
| Close Issue | `gh issue close` |
| Check duplicate PR | `gh pr list` |
| Lookup parent Issue number | `gh issue list --json number` |

### Duplicate PR guard

`chapter save` checks whether a PR from the same head branch already exists before creating a new one. If it does, the command exits cleanly without error.

### Issue linking

Each level automatically links to its parent:
- Chapter Issue body includes `Parent: #BOOK_ISSUE`
- Page Issue body includes `Parent: #CHAPTER_ISSUE`

When parent Issues cannot be found automatically (e.g. in manual mode), tb2 continues without the link and shows a warning.

### Closing Issues

`chapter save --close-issue` closes the Chapter Issue with a comment after PR creation.

---

## Update / Uninstall

### Update

```sh
tb2 update
```

Pulls the latest version from GitHub, preserving your `config.list` settings.

### Uninstall

```sh
tb2 uninstall
```

Removes the installation directory and the `tb2` symlink.

---

## Complete Workflow

```sh
# 1. Configure
tb2 config set GH_OWNER_NAME "my-org"
tb2 config set GH_REPO_NAME  "textbook"

# 2. Create a book
tb2 book new -b Cryptography -t

# 3. Create a chapter
tb2 chapter new -b Cryptography -c RSA -t

# 4. Create and edit pages
tb2 page new -b Cryptography -c RSA -p Introduction -t
tb2 page edit -b Cryptography -c RSA -p Introduction

# 5. Save the page
tb2 page save -b Cryptography -c RSA -p Introduction

# 6. Create PR for the chapter
tb2 chapter save -b Cryptography -c RSA --close-issue

# 7. Build and preview
tb2 book build --open

# 8. Check status
tb2 status --remote
```

---

## Contributing

- **Branch**: `main` only
- **Commit messages**: short, descriptive English
- **Language**: Bash only
- **Indentation**: 2 spaces, no tabs
- **Strict mode**: all scripts must include `set -euo pipefail`
- **Shebang**: `#!/usr/bin/env bash` only
- **Checks**: run `./check.sh` before committing

### Release

Tag with `v*` to trigger CI → CD:

```sh
git tag v2
git push --tags
```

### Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md)

---

For more information: https://github.com/techno-tutors/tb2