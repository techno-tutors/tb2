# tb2

A simple toolbox bash script for textbook management using GitHub Issues.
This automates the creation and management of educational content through the Issue hierarchy system.
TB2 provides both interactive and command-line modes for efficient workflow.
(TextBook ToolBox === TB2)

## About
- *[Installation](#how-to-install)*
- *[Configuration](#configuration)*
- *[Usage](#usage)*
- *[Example](#example)*
- *[License](#license)*
- *[Contribute Rules](#contribute)*

## How to Install
3 opts, all one-line so you can now copy-and-paste to run.

### use GIT
```sh
git clone https://github.com/techno-tutors/tb2.git;
cd tb2;
sh ./install.sh;
```

### use CURL
```sh
curl -fsSL https://raw.githubusercontent.com/techno-tutors/tb2/refs/heads/main/install.sh | sh
```

### use WGET
```sh
wget -qO- https://raw.githubusercontent.com/techno-tutors/tb2/refs/heads/main/install.sh | sh
```

## Configuration
Before using tb2, you must configure the following settings:
```sh
# Set your GitHub username or organization name
tb2 config set GH_OWNER_NAME "YOUR_GITHUB_USERNAME"
# Set the mdBook series name (used as a prefix for organization)
tb2 config set MDBOOK_SERIES_NAME "YOUR_SERIES_NAME"
# Set the source directory for your mdBook content
tb2 config set MDBOOK_SRC_DIR "src"
# Set the branch name for operations (usually "draft")
tb2 config set TB2_OPERATION_BRANCH "draft"
# Set the GitHub repository for Issue management (REQUIRED)
# This repository will contain the Issue hierarchy
tb2 config set PROJECT_NAME "owner/repository"
```
The `PROJECT_NAME` is the most important configuration. All book, chapter, and page issues will be created in this repository.

## Usage
### Issue Hierarchy System
TB2 uses GitHub Issues organized in a three-level hierarchy:
- **Issue (Level 1)**: Book - Each book is represented as a top-level issue
- **Sub-Issue (Level 2)**: Chapter - Each chapter is a child issue under a book issue
- **Sub-Sub-Issue (Level 3)**: Page - Each page is a child issue under a chapter issue

### subcmd "book"
```sh
tb2 book new -b BOOKNAME
```
Create a new book project.

#### GitHub Operations
- Creates a new Issue titled "Book: BOOKNAME" in the configured repository
- Creates a local directory at `MDBOOK_SRC_DIR/BOOKNAME`

___

```sh
tb2 book list
```
List all books.

___

### subcmd "chapter"
```sh
tb2 chapter new -c CHAPTERNAME -b BOOKNAME
```
Create a new chapter within a book.

#### GitHub Operations
- Creates a new Issue titled "Chapter: CHAPTERNAME" linked to the parent book issue
- Creates a chapter branch (`chapter/CHAPTERNAME`) from the operation branch
- Creates a local directory at `MDBOOK_SRC_DIR/BOOKNAME/CHAPTERNAME`

___

```sh
tb2 chapter save -c CHAPTERNAME -b BOOKNAME
```
Save chapter changes as a pull request.

#### GitHub Operations
- Creates a pull request from the chapter branch to the operation branch

___

```sh
tb2 chapter list -b BOOKNAME
```
List all chapters in a book.

___

### subcmd "page"
```sh
tb2 page new -b BOOKNAME -c CHAPTERNAME [-p PAGENAME]
```
Create a new page within a chapter.
If PAGENAME is omitted, pages are auto-numbered as p1, p2, etc.

#### GitHub Operations
- Creates a new Issue titled "Page: PAGENAME (CHAPTERNAME)" linked to the parent chapter issue
- Creates a markdown file at `MDBOOK_SRC_DIR/BOOKNAME/CHAPTERNAME/PAGENAME.md`

___

```sh
tb2 page save -b BOOKNAME -c CHAPTERNAME -p PAGENAME
```
Save page changes by committing and pushing.

#### GitHub Operations
- Commits and pushes the page changes to the repository

___
```sh
tb2 page list -b BOOKNAME -c CHAPTERNAME
```
Display all pages in the chapter.
___

### subcmd "project"
```sh
tb2 project list
```
Display all books and chapters in the project.

___

```sh
tb2 project list -p|-page
```
Display all books, chapters, and their contained pages.

___

### Interactive Mode
```sh
tb2 [-i]
```
Launch the interactive mode for guided workflow.

## Example
TB2 automates the textbook creation workflow using GitHub Issues for management and Git for version control.
Below is a complete example of creating a book, chapter, and page structure:

### Setup
First, configure TB2 with your repository information:
```sh
tb2 config set PROJECT_NAME "techno-tutors/textbook"
tb2 config set GH_OWNER_NAME "techno-tutors"
tb2 config set MDBOOK_SERIES_NAME "MyTextbook"
tb2 config set MDBOOK_SRC_DIR "src"
tb2 config set TB2_OPERATION_BRANCH "draft"
```

### 1. **Create a Book**
```sh
tb2 book new -b Crypto
```
- Creates a GitHub Issue titled "Book: Crypto" in the repository `techno-tutors/textbook`
- Creates a local directory at `src/Crypto`

### 2. **Create a Chapter**
```sh
tb2 chapter new -b Crypto -c RSA
```
- Creates a GitHub Issue titled "Chapter: RSA" linked to the "Book: Crypto" issue
- Creates a new branch `chapter/RSA` from the `draft` branch
- Creates a local directory at `src/Crypto/RSA`

### 3. **Create Pages**
```sh
tb2 page new -b Crypto -c RSA -p WhatIsRSA
```
- Creates a GitHub Issue titled "Page: WhatIsRSA (RSA)" linked to the "Chapter: RSA" issue
- Creates a markdown file at `src/Crypto/RSA/WhatIsRSA.md`
- You can create multiple pages in the same chapter

### 4. **Edit Your Content**
Edit the markdown files in your text editor:
```sh
nano src/Crypto/RSA/WhatIsRSA.md
```

### 5. **Save Page Changes**
```sh
tb2 page save -b Crypto -c RSA -p WhatIsRSA
```
- Commits and pushes the page changes to the repository on the chapter branch
- Not like "-p WhatIsRSA.md".

### 6. **Finalize the Chapter**
```sh
tb2 chapter save -b Crypto -c RSA
```
- Creates a pull request from the `chapter/RSA` branch to the `draft` branch
- The "Chapter: RSA" issue remains open for tracking

### 7. **Review Your Progress**
```sh
tb2 project list
#or with pages
tb2 project list -page
```
- Displays the complete hierarchy of books, chapters, and pages
- Shows your progress in a structured format

## GitHub Issue Hierarchy Example
After completing the above steps, your repository will have:

```
Issue: Book: Crypto (#1)
├─ Issue: Chapter: RSA (#2)
│  └─ Issue: Page: WhatIsRSA (RSA) (#3)
└─ Issue: Chapter: Elliptic Curves (#4)
   ├─ Issue: Page: Introduction to EC (#5)
   └─ Issue: Page: ECC vs RSA (#6)
```

Corresponding local directory structure:
```
src/Crypto/
├── RSA/
│   └── WhatIsRSA.md
└── EllipticCurves/
    ├── Introduction.md
    └── Comparison.md
```


## LICENSE
ISC License. It is almost the same as MIT License.

## Contribute
- Branch: Only "main"
- Commit Msg Pattern: Short English
- Code Lang: Bash
- Code style: Mustn't use external command usually.
- Dir:
  - /install.sh[bash]
  - /script/tb2[bash]
  - /script/subcmds/subcmdname.d[dir]
  - /script/subcmds/subcmdname.d/cmdname[bash]
  - /script/subcmds/subcmdname.d/subcmds/subsubcmdname[bash]
- Indent: 2 spaces
- You have to add `set -euo pipefail` to head of bash file
- Shebang is allowed only `#!/usr/bin/env bash`
- tag `v*` commit to Release