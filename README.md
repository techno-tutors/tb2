# tb2

A simple toolbox bash script for textbook management using GitHub Issues and mdBook.
This automates the creation and management of educational content through a three-level Issue hierarchy system.
TB2 provides both interactive and command-line modes for efficient workflow.

**TextBook ToolBox === TB2**

now this is v1.

## Table of Contents
- [About](#about)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
  - [Issue Hierarchy System](#issue-hierarchy-system)
  - [Book Commands](#book-commands)
  - [Chapter Commands](#chapter-commands)
  - [Page Commands](#page-commands)
  - [Project Commands](#project-commands)
  - [Interactive Mode](#interactive-mode)
- [Complete Workflow Example](#complete-workflow-example)
- [GitHub Operations](#github-operations)
- [Manual Mode](#manual-mode)
- [License](#license)
- [Contributing](#contributing)

## About

TB2 is a command-line tool that integrates GitHub Issues with mdBook projects, providing:
- Hierarchical issue management (Book → Chapter → Page)
- Automated branch creation and pull request workflows
- Both CLI and interactive modes
- Integration with GitHub CLI for seamless GitHub operations
- Local mdBook project structure management

## Installation

Choose one of the following three installation methods:

### Using cURL
```sh
curl -fsSL https://raw.githubusercontent.com/techno-tutors/tb2/refs/heads/main/install.sh | sh
```

### Using wget
```sh
wget -qO- https://raw.githubusercontent.com/techno-tutors/tb2/refs/heads/main/install.sh | sh
```

## Uninstallation and Updation
see [Install Section](#installation) and change file path "install.sh" to "update.sh" or "uninstall.sh".

## Prerequisites

TB2 requires the following tools:
- **mdBook**: Install from https://github.com/rust-lang/mdBook
- **GitHub CLI (gh)**: Install from https://cli.github.com/ (not required in manual mode)
- **Git**: Standard git installation
- **Bash**: Version 4.0 or later

## Configuration

Before using tb2, configure the following settings:

```sh
# Set your GitHub username or organization name
tb2 config set GH_OWNER_NAME "YOUR_GITHUB_USERNAME"

# Set your GitHub repository name
tb2 config set GH_REPO_NAME "YOUR_REPOSITORY_NAME"

# Set the source directory for your mdBook content (default: "src")
tb2 config set MDBOOK_SRC_DIR "src"

# Set the branch name for operations (typically "draft")
tb2 config set TB2_OPERATION_BRANCH "draft"

# Set GitHub CLI mode: "auto" or "manual" (default: "auto")
tb2 config set GH_CLI_MODE "auto"
```

### Configuration Keys

| Key                    | Description                          | Default    |
| ---------------------- | ------------------------------------ | ---------- |
| `GH_OWNER_NAME`        | GitHub username or organization      | (required) |
| `GH_REPO_NAME`         | GitHub repository name               | (required) |
| `MDBOOK_SRC_DIR`       | mdBook source directory              | `src`      |
| `TB2_OPERATION_BRANCH` | Branch for operations                | `draft`    |
| `GH_CLI_MODE`          | GitHub CLI mode (`auto` or `manual`) | `auto`     |

### Viewing Configuration

```sh
# View a specific configuration value
tb2 config get GH_OWNER_NAME

# View all configurations
cat script/subcmds/config.d/config.list
```

## Usage

### Issue Hierarchy System

TB2 uses GitHub Issues organized in a three-level hierarchy:

```
Book (GitHub Issue)
└── Chapter (GitHub Issue + Branch)
    └── Page (GitHub Issue + File)
```

- **Book**: Top-level organization unit (creates Issue + directory)
- **Chapter**: Section within a book (creates Issue + branch + directory)
- **Page**: Individual content page (creates Issue + markdown file)

### Book Commands

#### Create a new book
```sh
tb2 book new -b BOOKNAME
```

**What it does:**
- Creates a GitHub Issue titled "Book: BOOKNAME"
- Creates a local directory at `MDBOOK_SRC_DIR/BOOKNAME`
- Optionally commits and pushes to the operation branch

**Example:**
```sh
tb2 book new -b Cryptography
```

#### List all books
```sh
tb2 book list
```

**What it does:**
- Lists remote books (GitHub Issues with "Book:" prefix)
- Lists local book directories in `MDBOOK_SRC_DIR`

### Chapter Commands

#### Create a new chapter
```sh
tb2 chapter new -b BOOKNAME -c CHAPTERNAME
```

**What it does:**
- Creates a GitHub Issue titled "Chapter: CHAPTERNAME" linked to parent Book Issue
- Creates a new branch `chapter/CHAPTERNAME` from the operation branch
- Creates a local directory at `MDBOOK_SRC_DIR/BOOKNAME/CHAPTERNAME`
- Optionally commits and pushes to the chapter branch

**Example:**
```sh
tb2 chapter new -b Cryptography -c RSA
```

#### Save chapter (create pull request)
```sh
tb2 chapter save -b BOOKNAME -c CHAPTERNAME
```

**What it does:**
- Creates a pull request from `chapter/CHAPTERNAME` to the operation branch
- Pull request title: "Add chapter: CHAPTERNAME (BOOKNAME)"

**Example:**
```sh
tb2 chapter save -b Cryptography -c RSA
```

#### List chapters in a book
```sh
tb2 chapter list -b BOOKNAME
```

**What it does:**
- Lists local chapters (subdirectories in book directory)
- Lists remote chapters (GitHub Issues with "Chapter:" prefix for the book)

**Example:**
```sh
tb2 chapter list -b Cryptography
```

### Page Commands

#### Create a new page
```sh
tb2 page new -b BOOKNAME -c CHAPTERNAME [-p PAGENAME]
```

**What it does:**
- Creates a GitHub Issue titled "Page: PAGENAME (CHAPTERNAME)" linked to parent Chapter Issue
- Creates a markdown file at `MDBOOK_SRC_DIR/BOOKNAME/CHAPTERNAME/PAGENAME.md`
- If `-p` is omitted, auto-generates page names as `p1`, `p2`, `p3`, etc.

**Examples:**
```sh
# With explicit page name
tb2 page new -b Cryptography -c RSA -p Introduction

# Auto-numbered page
tb2 page new -b Cryptography -c RSA
# Creates p1.md, p2.md, etc.
```

#### Save page changes
```sh
tb2 page save -b BOOKNAME -c CHAPTERNAME -p PAGENAME
```

**What it does:**
- Commits the page file with message "Page: PAGENAME in CHAPTERNAME"
- Pushes changes to the current chapter branch

**Example:**
```sh
tb2 page save -b Cryptography -c RSA -p Introduction
```

**Note:** Use `-p Introduction`, not `-p Introduction.md`

#### List pages in a chapter
```sh
tb2 page list -b BOOKNAME -c CHAPTERNAME
```

**What it does:**
- Lists remote pages (GitHub Issues with "Page:" prefix for the chapter)
- Lists local pages (markdown files in the chapter directory)

**Example:**
```sh
tb2 page list -b Cryptography -c RSA
```

### Project Commands

#### List project structure
```sh
tb2 project list
```

**What it does:**
- Displays all books and their chapters in tree structure

#### List project structure with pages
```sh
tb2 project list -p
```

**What it does:**
- Displays complete hierarchy: books, chapters, and pages

**Example output:**
```
=Local [mdBooks project]=
========================================
[bok]Cryptography
  [chap]RSA
    [pag]Introduction
    [pag]KeyGeneration
  [chap]EllipticCurves
    [pag]Overview
========================================
```

### Interactive Mode

Launch the interactive mode for a guided workflow:

```sh
tb2
# or
tb2 -i
```

**Available commands in interactive mode:**
- `book` - Book management menu
- `chapter` - Chapter management menu
- `page` - Page management menu
- `project` - Project view menu
- `help` - Show help
- `exit` or `quit` - Exit interactive mode

The interactive mode provides numbered menus for each operation and prompts for required inputs.

## Complete Workflow Example

Here's a complete example of creating a cryptography textbook:

### 1. Initial Setup

```sh
# Configure TB2
tb2 config set GH_OWNER_NAME "techno-tutors"
tb2 config set GH_REPO_NAME "textbook"
tb2 config set MDBOOK_SRC_DIR "src"
tb2 config set TB2_OPERATION_BRANCH "draft"
```

### 2. Create a Book

```sh
tb2 book new -b Cryptography
# Creates:
# - GitHub Issue: "Book: Cryptography"
# - Directory: src/Cryptography/
```

### 3. Create a Chapter

```sh
tb2 chapter new -b Cryptography -c RSA
# Creates:
# - GitHub Issue: "Chapter: RSA" (linked to Book Issue)
# - Branch: chapter/RSA
# - Directory: src/Cryptography/RSA/
```

### 4. Create Pages

```sh
# Create first page with explicit name
tb2 page new -b Cryptography -c RSA -p Introduction
# Creates:
# - GitHub Issue: "Page: Introduction (RSA)"
# - File: src/Cryptography/RSA/Introduction.md

# Create additional pages (auto-numbered)
tb2 page new -b Cryptography -c RSA
# Creates: src/Cryptography/RSA/p1.md

tb2 page new -b Cryptography -c RSA
# Creates: src/Cryptography/RSA/p2.md
```

### 5. Edit Content

```sh
# Edit your markdown files
nano src/Cryptography/RSA/Introduction.md
# Write your content...
```

### 6. Save Page Changes

```sh
tb2 page save -b Cryptography -c RSA -p Introduction
# Commits and pushes to branch chapter/RSA
```

### 7. Complete the Chapter

```sh
tb2 chapter save -b Cryptography -c RSA
# Creates pull request from chapter/RSA to draft branch
```

### 8. Review Progress

```sh
tb2 project list -p
# Displays complete project hierarchy
```

## GitHub Operations

### Issue Hierarchy Example

After completing the workflow above, your GitHub repository will have:

```
Issue #1: Book: Cryptography
├── Issue #2: Chapter: RSA (linked to #1)
│   ├── Issue #3: Page: Introduction (RSA) (linked to #2)
│   ├── Issue #4: Page: p1 (RSA) (linked to #2)
│   └── Issue #5: Page: p2 (RSA) (linked to #2)
└── Issue #6: Chapter: EllipticCurves (linked to #1)
    └── Issue #7: Page: Overview (EllipticCurves) (linked to #6)
```

### Branch Structure

- `draft` - Main operation branch (configured via `TB2_OPERATION_BRANCH`)
- `chapter/RSA` - Chapter working branch
- `chapter/EllipticCurves` - Another chapter working branch

### Directory Structure

```
src/
└── Cryptography/
    ├── RSA/
    │   ├── Introduction.md
    │   ├── p1.md
    │   └── p2.md
    └── EllipticCurves/
        └── Overview.md
```

## Manual Mode

TB2 can operate without GitHub CLI by using manual mode:

```sh
tb2 config set GH_CLI_MODE "manual"
```

In manual mode:
- TB2 will display instructions for manual GitHub operations
- You create Issues and PRs manually through GitHub's web interface
- Local file operations continue to work normally
- `book list`, `chapter list`, and `page list` won't show remote Issues

This is useful when:
- GitHub CLI is not available
- You prefer manual control over GitHub operations
- You're working in a restricted environment

## License

ISC License (essentially equivalent to MIT License)

Copyright (c) 2026 Contributors in Techno-Tutors

Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.

## Contributing

### Guidelines

- **Branch**: Only `main` branch
- **Commit Messages**: Short, descriptive English
- **Code Language**: Bash only
- **External Commands**: Minimize use of external commands when possible
- **Indentation**: 2 spaces (no tabs)
- **Strict Mode**: All bash files must include `set -euo pipefail`
- **Shebang**: Only `#!/usr/bin/env bash` is allowed
- **Code Checks**: Run `./check.sh` before committing (requires `shfmt`, `shellcheck`, `shellharden`)

### Directory Structure

```
/
├── install.sh                          # Installation script
├── script/
│   ├── tb2                             # Main entry point
│   ├── utils.sh                        # Utility functions
│   ├── interactive/
│   │   ├── main.sh                     # Interactive mode entry
│   │   └── funcs.sh                    # Interactive mode functions
│   └── subcmds/
│       ├── config.d/
│       │   ├── config                  # Config command
│       │   └── config.list             # Config storage
│       ├── book.d/
│       │   ├── book                    # Book command dispatcher
│       │   └── subcmds/
│       │       ├── new                 # book new subcommand
│       │       └── list                # book list subcommand
│       ├── chapter.d/
│       │   ├── chapter                 # Chapter command dispatcher
│       │   └── subcmds/
│       │       ├── new                 # chapter new
│       │       ├── save                # chapter save
│       │       └── list                # chapter list
│       ├── page.d/
│       │   ├── page                    # Page command dispatcher
│       │   └── subcmds/
│       │       ├── new                 # page new
│       │       ├── save                # page save
│       │       └── list                # page list
│       ├── project.d/
│       │   ├── project                 # Project command dispatcher
│       │   └── subcmds/
│       │       └── list                # project list
│       └── help.d/
│           └── help                    # Help command
```

### Release Process

- Tag commits with `v*` pattern for releases
- Example: `git tag v1.0.0` then `git push --tags`

### Contributors

See [CONTRIBUTORS.md](CONTRIBUTORS.md)

---

For more information, visit: https://github.com/techno-tutors/tb2