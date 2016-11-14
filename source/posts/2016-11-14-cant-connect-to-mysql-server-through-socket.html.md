---
title: Can't connect to local MySQL server through socket '/tmp/mysql.sock'
date: 2016-11-14
tags: MySQL
author: kohei
ogp:
  og: 'PHPからMySQLサーバーへアクセスしようとした際、以下のようなエラーが発生しました。'
---

# はじめに
PHPからMySQLサーバーへアクセスしようとした際、以下のようなエラーが発生しました。
> SQLSTATE[HY000] [2002] Can't connect to local MySQL server through socket '/tmp/mysql.sock' 

**「ソケット'_/tmp/mysql.sock_'を通してローカルのMySQLサーバへアクセスができません。」**といった内容です。

MySQLは起動時に_mysql.sock_というソケットファイルを作成します。そしてPHPや他のプログラムはこのソケットファイルを通してMySQLへアクセスを行うことができます。
どうやらここが怪しそうです。


# 調査
といことで、このPHPエラーが_/tmp/mysql.sock_へアクセスしようとしていたということなので、まずは_/tmp/mysql.sock_があることを確認してみます。

```bash:確認1(mysql.sock)
$ ls /tmp/mysql.sock
ls: /tmp/mysql.sock にアクセスできません: そのようなファイルやディレクトリはありません
```

おぉ、そもそもアクセスしようとしている場所に_mysql.sock_がないみたいです。。。
ではどこにあるのでしょうか？？？
_my.cnf_を見てみます。

```bash:確認2(mysql.sock)
$ grep mysql.sock /etc/my.cnf
socket          = /var/lib/mysql/mysql.sock
socket          = /var/lib/mysql/mysql.sock
```
ここで設定されているのは_/va/lib/mysql/mysql.sock_です。
ちなみに2つ存在するのは**[client]**と**[mysqld]**で設定されているからです。
では、確かめてみます。

```bash:確認3(mysql.sock)
$ ls /var/lib/mysql/mysql.sock
/var/lib/mysql/mysql.sock
```
ありました。

# 原因
これでわかったのが、
**「MySQLはソケットを_/var/lib/mysql/mysql.sock_に用意して待ち構えているけれど、PHPは_/tmp/mysql.sock_にソケットがあると思ってアクセスしにいっているためエラーが発生している。」**
ということです。

# 対策
なので今回は_my.cnf_を修正してソケットを_/tmp/mysql.sock_へ作成するように変更します。
まずはmysqlを停止しておきましょう。

```bash:mysql停止
$ sudo service mysqld stop
Shutting down MySQL. SUCCESS!
```

それでは修正します。

```bash:my.cnf修正
$ vi /etc/my.cnf
$ grep mysql.sock /etc/my.cnf
socket          = /tmp/mysql.sock
socket          = /tmp/mysql/mysql.sock
```

起動します。

```bash:mysql起動
$ sudo service mysqld start
Starting MySQL. SUCCESS! 
```

それではソケットが作成されたか確認しましょう。

```bash:確認
$ ls /tmp/mysql.sock
/tmp/mysql.sock
```
無事、指定した場所に作成されました。

```bash:
$ tail -f /var/log/mysql/mysql.log
		     30 Connect     hogehoge@localhost on hogehoge
		     30 Quit       
		     32 Connect     hogehoge@localhost on hogehoge
		     31 Connect     hogehoge@localhost on hogehoge
		     32 Quit       
		     31 Quit
```
アクセスログも正常に出力されているみたいです。

以上で、エラーは解消されました。


# おわりに
今回は受け手となるMySQL側のソケットデフォルト位置と送り手となるPHP側MySQLのデフォルトソケット位置が異なるために発生したエラーでした。
念のため対応後、PHP側の設定(php.ini)を確認したところ、MySQLソケットを指定する箇所に指定がありませんでした。

```bash:
$ grep socket /etc/php.ini
; Default timeout for socket based streams (seconds)
default_socket_timeout = 60
; Default socket name for local MySQL connects.  If empty, uses the built-in
mysql.default_socket =
; Default socket name for local MySQL connects.  If empty, uses the built-in
mysqli.default_socket =
```
なのでこちらでMySQLのソケット位置を設定してあげても良かったかもです。

ということで、とりあえず今回は、MySQL側の設定(_my.cnf_)を指定することで対応しましたが、PHP側の設定(_php.ini_)で対応しても解決できたと思われます。

