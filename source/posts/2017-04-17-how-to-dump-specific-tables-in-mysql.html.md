---
title: MySQLで特定のテーブルをdumpする方法。
date: 2017-04-17
tags: MySQL
author: kohei
ogp:
  og: '特定のテーブルを指定してdumpするには以下の方法で行えます。'
---

# はじめに
特定のテーブルを指定してdumpするには以下の方法で行えます。

```bash:コマンド
$ mysqldump -u<ユーザー> -p<パスワード> 【データベース】 【テーブル１】 【テーブル２】 ... --master-data --single-transaction > hogehoge.dump
```

データベースの後にテーブル名を並べれば良いのですが、数が増えてくると大変です。。。そんな時はテーブルリストを作成し、それを使ってdumpを行うと簡単になります。


<br>
# 実践
実際のデータベースを使って試してみます。
まずはrepltestというデータベースに以下のテーブルが存在します。

```bash:テーブル一覧
$ mysql -uroot repltest -e "show tables"
+--------------------+
| Tables_in_repltest |
+--------------------+
| hogehoge1          |
| hogehoge2          |
| hogehoge3          |
| hogehoge4          |
| hogehoge5          |
| test1              |
| test2              |
| test3              |
| test4              |
| test5              |
| user1              |
| user2              |
| user3              |
| user4              |
| user5              |
+--------------------+
```

ここで、hogeから始まるテーブルのみを抽出してみます。

```bash:hoge抽出
$ mysql -uroot repltest -N -e "show tables like 'hoge%'"
+-----------+
| hogehoge1 |
| hogehoge2 |
| hogehoge3 |
| hogehoge4 |
| hogehoge5 |
+-----------+
```

|オプション|内容|
|:------|:--|
|[-N, --skip-column-names](https://dev.mysql.com/doc/refman/5.6/ja/mysql-command-options.html#option_mysql_skip-column-names)|カラム名を表示しない|

これをテキストに書き出すと、

```bash:テキストへ書き出し
$ mysql -uroot -phogehoge repltest -N -e "show tables like 'hoge%'" > repltest.txt
```

```bash:表示
$ cat repltest.txt 
hogehoge1
hogehoge2
hogehoge3
hogehoge4
hogehoge5
```
このようにhogeから始まるテーブルのみ一覧としてリストできました。


あとはこのリストをcatコマンドを使いながらdumpすれば完了です。

```bash:dump
$ mysqldump -uroot -phogehoge repltest `cat ./repltest.txt` --master-data --single-transaction > repltest.dump
```


<br>
# おわりに
mysqldumpのオプションで `--ignore-table=<database>.<table>` があります。ですが複数テーブル除外したい場合は、その数だけ `--ignore-table=<database>.<table>` を並べないといけないデメリットがあります。
そんな場合は一旦dumpしたいテーブルをリストとして書き出し、そのリストを利用してdumpしてしまった方が簡単かもしれません。
