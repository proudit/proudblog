---
title: Redmineのバージョンを確認する。 
date: 2016-02-15
tags: Redmine
author: kohei
---

Redmineのバージョンを確認する方法です。

方法としては「1.管理画面で確認」「2.コマンドで確認」「3.ソースコードで確認」の３通り紹介します。

# 1.管理画面で確認
##### 1-1.管理者権限のあるアカウントでRedmineへログインします。
##### 1-2.「管理」をクリックします。
<img width="332" alt="20160112_redmine01.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/df5492e0-2af2-5c90-4946-9db76e5d44ab.png">

##### 1-3.「情報」をクリックします。
<img width="202" alt="20160112_redmine02.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/84d8540b-d699-5aa6-382b-ba8baeeac291.png">

##### 1-4.画面上部に表示されます。
<img width="995" alt="20160112_redmine03.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/ee8ee97a-9344-6619-97d5-78f4e01f30a7.png">

バージョンの他にも、
・Redmineのインストールの正常性
・データベースの種類
・Rdmineの実行環境
などが確認できます。

<br>
# 2.コマンドで確認
##### 2-1.サーバへログインし、Redmineをインストールしたディレクトリへ移動します。
##### 2-2.以下のコマンドを実行します。
※旧バージョンだとscript/aboutの場合があります。

```bash:コマンド
$ ruby bin/about 
```

```output:実行結果
Environment:
  Redmine version                3.2.0.stable
  Ruby version                   2.0.0-p647 (2015-08-18) [x86_64-linux]
  Rails version                  4.2.5
  Environment                    production
  Database adapter               Mysql2
SCM:
  Subversion                     1.8.13
  Git                            2.4.3
  Filesystem                     
Redmine plugins:
  no plugin installed
```

管理画面で表示されているものと同等の内容が確認できます。


<br>
# 3.ソースコードで確認
##### 3-1.サーバへログインし、Redmineをインストールしたディレクトリへ移動します。
lib/redmine/version.rbの冒頭にバージョンを表す数値が定義されています。

```bash:コマンド
$ cat lib/redmine/version.rb 
require 'rexml/document'

module Redmine
  module VERSION #:nodoc:
    MAJOR = 3
    MINOR = 2
    TINY  = 0
```

以上の３つの方法がありますが。
管理権限付きのユーザーを持っているのであれば「1.管理画面で確認」を行うのが一番良さそうです。
もし、管理画面へログインするアカウントがい場合は「2.コマンドで確認」が有効です。
また、「3.ソースコードで確認」は一応紹介しましたが、これを行うのであれば、「2.コマンドで確認」を行う方が良いです。
