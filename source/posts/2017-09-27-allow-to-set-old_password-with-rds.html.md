---
title: "Amazon RDS for MySQL で OLD_PASSWORD を設定する。"
date: 2017-09-27
tags: AWS, RDS, MySQL
author: kohei
ogp:
  og: 'Amazon RDS for MySQL では、デフォルト状態だと OLD_PASSWORD が利用できません。
古いバージョンのシステムからアクセスする場合など、どうしても OLD_PASSWORD を利用しないといけない場合があ
る場合の設定です'
---

# はじめに
**Amazon RDS for MySQL** では、デフォルト状態だと __OLD_PASSWORD__ が利用できません。
古いバージョンのシステムからアクセスする場合など、どうしても _OLD_PASSWORD_ を利用しないといけない場合がある場合の設定です。


<br>
# 設定
とりあえず _OLD_PASSWORD_ を有効にして設定して見ます。

```mysql:old_passwordsの確認
mysql> SELECT @@session.old_passwords, @@global.old_passwords;
+-------------------------+------------------------+
| @@session.old_passwords | @@global.old_passwords |
+-------------------------+------------------------+
|                       1 |                      0 |
+-------------------------+------------------------+
1 row in set (0.00 sec)
```

```mysql:パスワード設定
mysql> SET PASSWORD FOR 'mysql'@'%' = OLD_PASSWORD('hogehoge');
ERROR 1372 (HY000): Password hash should be a 41-digit hexadecimal number
```

何やらエラーが。。。どうやら認証プラグインが違うみたいです。

>引用：[MySQL 5.6 リファレンスマニュアル 13.7.1.7 SET PASSWORD 構文](https://dev.mysql.com/doc/refman/5.6/ja/set-password.html) より
old_passwords 値が認証プラグインに必要な値と異なる場合は、PASSWORD() によって返されたハッシュされたパスワード値がそのプラグインに許容されず、パスワードを設定しようとするとエラーが生成されます。

認証プラグインを確認してみます。認証プラグインは各ユーザーごとに設定されているみたいです。

```mysql:認証プラグイン確認
mysql> select Host, User, plugin from mysql.user where User = "mysql"\G
*************************** 1. row ***************************
                  Host: %
                  User: mysql
                plugin: mysql_native_password
1 row in set (0.00 sec)
```

プラグインが `mysql_native_password` になってます。これが原因ですね。
ということで 認証プラグイン を `mysql_old_password` に変更してみます。

```mysql:認証プラグイン変更
mysql> update mysql.user set plugin = 'mysql_old_password' where User = "mysql";
Query OK, 1 row affected (0.09 sec)
Rows matched: 1  Changed: 1  Warnings: 0
```

```mysql:認証プラグイン確認
mysql> select Host, User, plugin from mysql.user where User = "mysql"\G
*************************** 1. row ***************************
                  Host: %
                  User: mysql
                plugin: mysql_old_password
1 row in set (0.00 sec)
```

無事変更できました。

では、もう一度変更して見ます。

```mysql:old_passwords有効化
mysql> SET SESSION old_passwords=1;
Query OK, 0 rows affected (0.00 sec)
```

```mysql:パスワード設定
mysql> GRANT SELECT ON *.* TO mysql@'%' IDENTIFIED BY 'hogehoge';
Query OK, 0 rows affected, 1 warning (0.01 sec)
```

今度は無事に設定できました。
それではちゃんとログインできるか確認してみます。

```bash:MySQLログイン
$ mysql -hrdstest.cemnknnpakxg.ap-northeast-1.rds.amazonaws.com -umysql -phogehoge
ERROR 1275 (HY000): Server is running in --secure-auth mode, but 'mysql'@'***.***.***.***' has a password in the old format; please change the password to the new format
```

何やら `--secure-auth` モードが邪魔してるみたいです。。。

```mysql:パラメータ変更
mysql> SET GLOBAL secure_auth= 0;
ERROR 1227 (42000): Access denied; you need (at least one of) the SUPER privilege(s) for this operation
```
んー。。。これはパラメータグループで変更するしかなさそうです。

ということで 管理画面にログインしてRDSで利用してるパラメータグループから _secure_auth_ を無効にします。

それではもう一度ログイン。

```bash:MySQLログイン
$ mysql -hrdstest.cemnknnpakxg.ap-northeast-1.rds.amazonaws.com -umysql -phogehoge
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1599
Server version: 5.6.35-log MySQL Community Server (GPL)

Copyright (c) 2000, 2010, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

今度はログインできました。


<br>
# おわりに
・ユーザーの認証プラグインを変更 → mysql_old_password
・old_passwords のセッションを有効 → old_passwords
・パスワードの設定
・パラメータグループの変更 → secure_auth
で設定完了です。

とはいえ、この接続はセキュリティレベルを下げる行為なので極力避けた方が良いです。


