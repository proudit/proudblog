---
title: MySQL ibdataのデータサイズが肥大化した場合の対処方法。
date: 2016-10-31
tags: MySQL,Linux
author: kohei
ogp:
  og: '今回、とある案件でサーバの調査をしていた際に**ibdata1**のサイズがかなり大きくなっているのに気づきました。'
---

# はじめに
MySQLでibdata1のデータサイズが肥大化していた際の対処法。

今回、とある案件でサーバの調査をしていた際に**ibdata1**のサイズがかなり大きくなっているのに気づきました。
これは**InnoDB**のデータ領域(テーブルスペース)です。
こうなると稼働したままデータサイズを小さくするのは難しく、リストアが必要となります。


<br>
# 事前準備
リストア作業を行う前にデータベースを利用するサービスを停止またはメンテ表示にしてトランザクションが*mysql*へ来ないようにしておきましょう。


<br>
# 作業
## 1. mysqldumpの取得
サービスを停止したら対象となるデータベースの*dump*を取得します。
だいたいこういう時はデータサイズが大きいので`&`をつけて実行しておくと便利です。

```bash:コマンド
$ mysqldump -p****** -u root -B hogehoge > hogehoge.sql &
```


<br>
## 3. MySQLの停止
*dump*が取得できたらMySQLを停止します。

```bash:コマンド
$ sudo service mysqld stop
Shutting down MySQL.. SUCCESS!
```


<br>
## 4. my.cnfの修正
同じことを繰り返さないためにも設定ファイルを修正します。
まずは原因となる箇所を見てみます。

```text:my.cnf(デフォルト)
[mysqld]
innodb_data_file_path=ibdata1:10M:autoextend
```

ここに`autoextend`が記載されていると、テーブルスペースに空き領域がなくなると自動拡張します。そのため今回は肥大化に繋がりました。
これはデフォルト設定なので**InnoDB**を利用する場合は注意が必要です。

なのでこれを回避するために`autoextend`をやめて以下のように`innodb_file_per_table`を追加しました。

```text:my.cnf（変更後）
[mysqld]
innodb_data_file_path = ibdata1:1G
innodb_file_per_table
```
これはテーブルスペースをテーブル単位で作成する設定です。
そうすることでテーブルスペースが１つにまとまってしまうのを防ぐことができます。分散されるのでパフォーマンスも良くなるみたいです。


<br>
## 5. ibdata*とib_logfile*の削除
それでは肥大化した**ibdata**を削除します。その際、**ib_logfile**もあれば削除しておきます。

```bash:コマンド
$ rm -f ibdata1 ib_logfile*
```


<br>
## 6. MySQLを起動する
MySQLを起動します。その際に削除された**ibdata**も再度作成されるので起動に多少時間がかかります。

```bash:コマンド
$ sudo service mysqld start
Starting MySQL................. SUCCESS! 
```


<br>
## 7. dumpデータの流し込み
ここまできたらあとは、はじめに*dump*したデータを流し込むだけです。

```bash:コマンド
$ mysql -p****** -uroot < hogehoge.sql &
```
フルダンプでない場合、*dump*データの流し込みには対象となるデータベースを用意しておく必要があります。ない場合は作成しておくのをお忘れなく。

完了したら最後に、事前準備で停止していた関連サービスを起動またはメンテ解除すれば完了です。


<br>
# おわりに
**InnoDB**はトランザクション機能がポイントですが、それが故に今回のような状況に陥る可能性があるので注意が必要です。

