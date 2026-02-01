# tb2

A simple toolbox bash script for main repositry Textbook.
This contains GitHub automations, auto commit or auto issue for example.
This has 2 mode, Interactive and basic commands.
(TextBook ToolBox === TB2)

## About
- *[Installation](#how-to-install)*
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

## Usage
<GitHubの動き>にはGitのみの動作も含まれます。

---

### subcmd "book"
```sh
tb2 book new -b BOOKNAME
#または
tb2 book new BOOKNAME
```
新しい本NAMEを作成します。

#### GitHubの動き
- GitHub ProjectへBOOKNAMEが追加されます。

___

```sh
tb2 book list
```
本一覧を表示します。

___

### subcmd "chapter"
```sh
tb2 chapter new -c CHAPTERNAME -b BOOKNAME
#または
tb2 chapter new BOOKNAME/CHAPTERNAME
```
新しいチャプターNAMEを本BOOKNAMEに作成します。

#### GitHubの動き
- チャプター用のブランチがdraftから切られます。
- チャプター用のissueがProject(BOOKNAME)に立てられます。

___

```sh
tb2 chapter save -c CHAPTERNAME -b BOOKNAME
#または
tb2 chapter save BOOKNAME/CHAPTERNAME
```
チャプターを保存します。

#### GitHubの動き
- チャプター用のブランチをdraftブランチにプルリクエストします。

___

```sh
tb2 chapter list -b BOOKNAME
#または
tb2 chapter list BOOKNAME
```
本BOOKNAMEのチャプター一覧を表示します。

___

### subcmd "page"
```sh
tb2 page new -c CHAPTERNAME -b BOOKNAME [-p PAGENAME]
#または
tb2 page new BOOKNAME/CHAPTERNAME/PAGENAME
```
テンプレートからMDを作成します。  
-pを指定しなかった場合、ページの名前は連番でpageNとなります。

#### GitHubの動き
- SubIssueが立てられます。

___

```sh
tb2 page save -c CHAPTERNAME -b BOOKNAME -p PAGENAME
#または
tb2 page save CHAPTERNAME/BOOKNAME/PAGENAME
```
ページを保存します。

#### GitHubの動き
- コミット、及びその一連の流れをします。

___

### subcmd "project"
```sh
tb2 project list
```
プロジェクト全体の本とチャプターを表示します。

___

```sh
tb2 project list -p|-page
```
プロジェクト全体の本,チャプター,及びそれに含まれるページも表示します。

___

### Interactive Mode
```sh
tb2 [-i]
```

## Example
TB2を使うと、教科書制作のGitHub作業やディレクトリいじり、テンプレの適用などが自動化されます。
以下は、ツール直打ち（対話モードではない）で、本→チャプター→ページを作る一連の例です。

### 1. **本を作る**
```sh
tb2 book new Crypto
```
- GitHub Projectに`Crypto`が追加されます
-bで明示的にBOOKNAMEを指定してもいいけど略しても変わらん。

### 2. **チャプターを作る**
```sh
tb2 chapter new Crypto/RSA
#もしくは
tb2 chapter new -b Crypto -c RSA
```
- `draft`ブランチから`chapter/RSA`ブランチが作成されます
- "RSA"のIssueがProject(Crypto)に作成されます

### 3. **ページを書く**
```sh
tb2 page new Crypto/RSA/WhatIsRSA
```
ここで`-c`,`-b`,`-p`でわざわざ指定するのはめんどい。短縮形を使おう。
- Sub-Issue が作成されます
- `WhatIsRSA.md`が作成されます

### 4. **編集**
### 5. **ページを保存する**
```sh
tb2 page save Crypto/RSA/WhatIsRSA
```
- 変更がcommit&pushされます

### 6. **チャプターを完成させる**
```sh
tb2 chapter save Crypto/RSA
```
- `chapter/RSA`ブランチから`draft`ブランチにPRがつくられます。
- RSA chapterのissueはDONEやclosedにはなりません

### 7. **満足する**
```sh
tb2 project list -page
```
- 本 → チャプター → ページ の階層が一覧表示されます
自分が成し遂げた成果を見渡そう。


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
- Indent: 2 spaces or tab
- You havta do `shfmt`
- You havta add `set -euo pipfail` to head of bash file
- Shebang is allowd only `#!/us/bin/env bash`
- tag `v*` commit to Release