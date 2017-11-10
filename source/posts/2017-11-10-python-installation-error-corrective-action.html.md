---
title: "Mac OS X に Python のインストールを行った際にエラー(BUILD FAILED)が出たのでその対応方法。"
date: 2017-11-10
tags: Mac, python
author: kohei
ogp:
  og: 'macにpythonをインストールします。ただ、インストールしようとしたらエラーが出てきたので、その時に対応した内容もまとめて記載しときたいと思います'
---

# はじめに
macにpythonをインストールします。ただ、インストールしようとしたらエラーが出てきたので、その時に対応した内容もまとめて記載しときたいと思います。


<br>
# インストール
とりあえずpyenvで現在インストールされているpythonのバージョンを確認します。

```bash:バージョン確認
$ pyenv versions
* system (set by /Users/kohei/.pyenv/version)
```

出て来なかったということはインストールされていないみたいです。
では、現在の環境でインストールができるpythonのバージョンを確認します。

```bash:インストール可能バージョン確認
$ pyenv install -l  
Available versions:
  3.5.2
  3.5.3
  3.5.4
  3.6.0
  3.6-dev
  3.6.1
  3.6.2
  3.7-dev
```

3.7はdevとなっているので3.6.2を今回インストールしようと思います。

```bash:インストール
$ pyenv install 3.6.2
Downloading Python-3.6.2.tar.xz...
-> https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz
Installing Python-3.6.2...

BUILD FAILED (OS X 10.12.6 using python-build 20160602)

Inspect or clean up the working tree at /var/folders/39/1b_52_917csflbq7bxkrwb740000gp/T/python-build.20170928015417.61726
Results logged to /var/folders/39/1b_52_917csflbq7bxkrwb740000gp/T/python-build.20170928015417.61726.log

Last 10 log lines:
copying build/lib.macosx-10.12-x86_64-3.6/__pycache__/_sysconfigdata_m_darwin_darwin.cpython-36.opt-1.pyc -> /Users/kohei/.pyenv/versions/3.6.2/lib/python3.6/lib-dynload/__pycache__
dyld: lazy symbol binding failed: Symbol not found: _utimensat
  Referenced from: /private/var/folders/39/1b_52_917csflbq7bxkrwb740000gp/T/python-build.20170928015417.61726/Python-3.6.2/./python.exe
  Expected in: /usr/lib/libSystem.B.dylib

dyld: Symbol not found: _utimensat
  Referenced from: /private/var/folders/39/1b_52_917csflbq7bxkrwb740000gp/T/python-build.20170928015417.61726/Python-3.6.2/./python.exe
  Expected in: /usr/lib/libSystem.B.dylib

make: *** [sharedinstall] Abort trap: 6
```

すると`BUILD FAILED (OS X 10.12.6 using python-build 20160602)`。
なんだかエラーが出てしまいました。


<br>
# 対処

調べたら以下のブログを見つけました。
[MacでPython 3.5.0インストールに失敗したら](https://qiita.com/maosanhioro/items/bf93540515d4ea75b222)

`xcode-select --install`を実行すると良いみたいです。

```bash:xcodeインストール
$ xcode-select --install
xcode-select: note: install requested for command line developer tools
```

それでは再度インストールしてみます。

```bash:インストール
$ pyenv install 3.6.2
Downloading Python-3.6.2.tar.xz...
-> https://www.python.org/ftp/python/3.6.2/Python-3.6.2.tar.xz
Installing Python-3.6.2...
Installed Python-3.6.2 to /Users/kohei/.pyenv/versions/3.6.2
```

今回は無事にインストールできたみたいなので改めてバージョンを確認してみます。

```bash:バージョン確認
$ pyenv versions
* system (set by /Users/kohei/.pyenv/version)
  3.6.2
```

先ほどインストールしたバージョン(3.6.2)が表示されました。


<br>
# おわりに
`xcode-select`は結局なんなのか気になったので調べたところ、__XcodeやBSD 開発ツールにより使われるデベロッパディレクトリの場所を管理__するものだそうです。

```bash:manual
XCODE-SELECT(1)                                             BSD General Commands Manual                                            XCODE-SELECT(1)

NAME
       xcode-select - Manages the active developer directory for Xcode and BSD tools.

SYNOPSIS
       xcode-select [-h|--help] [-s|--switch <path>] [-p|--print-path] [-v|--version]

DESCRIPTION
       xcode-select  controls  the location of the developer directory used by xcrun(1), xcodebuild(1), cc(1), and other Xcode and BSD development
       tools. This also controls the locations that are searched for by man(1) for developer tool manpages.

       This allows you to easily switch between different versions of the Xcode tools and can be used to update the path to the  Xcode  if  it  is
       moved after installation.

   Usage
       When  multiple  Xcode  applications  are  installed  on  a system (e.g. /Applications/Xcode.app, containing the latest Xcode, and /Applica-
       tions/Xcode-beta.app containing a beta) use xcode-select --switch path/to/Xcode.app to specify the Xcode that you wish to use  for  command
       line developer tools.

       After  setting  a developer directory, all of the xcode-select provided developer tool shims (see FILES) will automatically invoke the ver-
       sion of the tool inside the selected developer directory. Your own scripts, makefiles, and other tools can  also  use  xcrun(1)  to  easily
       lookup  tools inside the active developer directory, making it easy to switch them between different versions of the Xcode tools and allow-
       ing them to function properly on systems where the Xcode application has been installed to a non-default location.
```

要は開発ツールのインストール先を指定するものらしいですね。また、異なるバージョンの切り替えもこのコマンドを使って行うことができるみたいです。

それでも「そうなんだ〜」くらいにしか感じませんが、とりあえず無事インストールできて良かったです。

