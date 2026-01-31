# tb2

A simple toolbox bash script for main repositry Textbook.
This contains GitHub automations, auto commit or auto issue for example.
This has 2 mode, Interactive and basic commands.
(TextBook ToolBox === TB2)

## About
- *[Installation](#how-to-install)*
- *[Usage](#usage)*
- *[License](#license)*
- *[Contribute Rules](#contribute)*

## How to Install
3 opts, all one-line so you can now copy-and-paste to run.

### use GIT
```sh
git clone https://GitHub.com/techno-tutors/tb2.git;
cd tb2;
sh ./install.sh;
```

### use CURL
```sh
curl -fsSL https://raw.GitHubusercontent.com/techno-tutors/tb2/refs/heads/main/install.sh | sh
```

### use WGET
```sh
wget -qO- https://raw.GitHubusercontent.com/techno-tutors/tb2/refs/heads/main/install.sh | sh
```

## Usage
<GitHubの動き>にはGitのみの動作も含まれます。

---

### subcmd "book"
```sh
tb2 book new -b NAME
#または
tb2 book new NAME
```
新しい本NAMEを作成します。

#### GitHubの動き
- GitHub ProjectへNAMEが追加されます。
- `-l`でGitHubへの自動適用を防止します。

___

```sh
tb2 book list
```
本一覧を表示します。

___

### subcmd "chapter"
```sh
tb2 chapter new -c NAME -b BOOKNAME
#または
tb2 chapter new BOOKNAME/NAME
```
新しいチャプターNAMEを本BOOKNAMEに作成します。

#### GitHubの動き
- チャプター用のブランチがdraftから切られます。
- チャプター用のissueがProject(BOOKNAME)に立てられます。

___

```sh
tb2 chapter save -c CHAPTERNAME -b BOOKNAME
#または
tb2 chapter save CHAPTERNAME BOOKNAME
```
チャプターを保存します。

#### GitHubの動き
- チャプター用のブランチをdraftブランチにプルリクエストします。

___

```sh
tb2 chapter list -b BOOKNAME
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

## LICENSE
ISC License. It is almost the same as MIT License.

## Contribute
- Branch: Only "main"
- Commit Msg Pattern: Short English
- Code Lang: Bash
- Code style: Mustn't use external command usually.
- Dir:
  - /install.sh
  - /script/tb2
  - /script/subcmds/subcmd_name
