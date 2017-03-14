---
title: MySQLでレプリケーションのセットアップ
date: 2017-03-14
tags: MySQL
author: kohei
ogp:
  og: 'MySQLの機能を使ってレプリケーション設定を行います。'
---

# はじめに
MySQLの機能を使ってレプリケーション設定を行います。


<br>
# ユーザー作成 & パラメーターの設定
まずはレプリケーションを行うための下準備です。

<br>
## レプリケーション用ユーザーの作成（マスター）
ここではスレーブからマスターへアクセスするためのユーザーを作成します。

```mysql:ユーザー作成
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'10.0.0.0/255.255.255.0' IDENTIFIED BY 'hogehoge';
Query OK, 0 rows affected (0.00 sec)
```

```text:ユーザー情報
ユーザー名：repl
権限：REPLICATION SLAVE
許可NW：10.0.0.0/24
パスワード：hogehoge
```
今回はスレーブ専用のユーザーのため権限はREPLICATION SLAVEのみ付与します。


<br>
## パラメーター設定(マスター)
続いてmy.cnfです。

```bash:my.cnf修正
$ sudo vim /etc/my.cnf
```

以下の２つのパラメーターをmy.cnfに追加します。

```text:追加(my.cnf)
[mysqld]
log-bin=db001-bin
server-id=205
```

MySQLではデフォルトではバイナリログが有効になっていないため、それを有効化します。
また、`server-id`はマスターとスレーブが自身を一意に識別するための設定です。


<br>
## MySQL再起動（マスター）
ユーザー作成とmy.cnfへのパラメーター追加が終わったらmysqlを再起動します。

```bash:mysql再起動
$ sudo /etc/init.d/mysqld restart
Stopping mysqld:                                           [  OK  ]
Starting mysqld:                                           [  OK  ]
```
以上でマスター側の設定が完了です。


<br>
## パラメーター設定（スレーブ）
スレーブ側はパラメーターの追加のみで大丈夫です。

```bash:my.cnf修正
$ vim /etc/my.cnf
```

```text:追加(my.cnf)
[mysqld]
server-id=39
```

<br>
## MySQL再起動（スレーブ）
追加したらこっちも再起動します。

```bash:mysql再起動
$ sudo /etc/init.d/mysqld restart
mysqld を停止中:                                           [  OK  ]
mysqld を起動中:                                           [  OK  ]
```
ということでレプリケーションのための下準備は完了です。


<br>
# レプリケーション
それでは実際にレプリーケションをセットアップします。

<br>
## レプリケーションデータ確認（マスター）
それでは実際にレプリケーションを組んで行きたいと思います。
今回は`repltest`をレプリケーションします。

```mysql:DB確認
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| repltest           |
| test               |
+--------------------+
5 rows in set (0.00 sec)
```

<br>
## テーブルロック（マスター）
まずはトラフィックが流れて来ないようにテーブルをロックします。

```bash:テーブルのロック
mysql> flush tables with read lock;
Query OK, 0 rows affected (0.00 sec)
```

<br>
## binファイル&ポジションの確認（マスター）
ロックしたらbinファイルとそのポジションを確認します。

```bash:binファイルとポジションの確認
mysql> show master status;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| db001-bin.000001 |      520 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.00 sec)
```

<br>
## dump(マスター)
それではレプリケーションするDBをdumpします。

```bash:ダンプ
$ mysqldump --databases repltest -u root -p --master-data --single-transaction > db001.dump
Enter password: 
```

```text:オプション
--master-data：バイナリログファイルの名前と場所を出力に書き込む
--single-transaction：サーバーからデータをダンプする前に BEGIN SQL ステートメントを発行
```

dumpが終わったらここでもbinファイルとポジションの確認をしておきましょう。

```bash:binファイルとポジションの確認
$ tail -100 db001.dump |grep -i "CHANGE MASTER TO"
CHANGE MASTER TO MASTER_LOG_FILE='db001-bin.000001', MASTER_LOG_POS=520;
```

さっきの`show master status;`と同じbinファイルとポジションが表示されるはずです。

<br>
## テーブルロックの解除（マスター）
問題なければロックを解除します。

```mysql:テーブルのロック解除
mysql> unlock tables;
Query OK, 0 rows affected (0.00 sec)
```


<br>
## データのリストア（スレーブ）
マスターでdumpしたファイルをスレーブへリストアします。

```bash:リストア
$ mysql -uroot -p < db001.dump 
Enter password: 
```

<br>
## マスター情報の設定（スレーブ）
リストアしたらマスター情報を設定します。

```mysql:マスタ情報の設定
mysql> change master to MASTER_HOST='10.0.0.205', MASTER_USER='repl', MASTER_PASSWORD='hogehoge', MASTER_LOG_FILE='db001-bin.000001', MASTER_LOG_POS=520;
Query OK, 0 rows affected (0.01 sec)
```

```text:オプション
MASTER_HOST：マスターホスト
MASTER_USER：接続ユーザー
MASTER_PASSWORD：接続ユーザーパスワード
MASTER_LOG_FILE：`show master status;`表示されたbinファイル名
MASTER_LOG_POS：`show master status;`で表示されたポジション
```

`MASTER_HOST`でマスターとなるホストを指定し、`MASTER_USER`と`MASTER_PASSWORD`でマスターへデータを取得しに行くユーザーとパスワードを指定しています。
`MASTER_LOG_FILE`と`MASTER_LOG_POS`は指定しないと`MASTER_LOG_FILE=''`と `MASTER_LOG_POS=4`が付加されてしまうのでちゃんと注意してください。


<br>
## START REPLICATION（スレーブ）
マスター情報を設定したらレプリケーションをスタートさせます。

```mysql:レプリケーションの開始
mysql> start slave;
Query OK, 0 rows affected (0.00 sec)
```
以上で完了です。


<br>
# レプリケーション確認
レプリケーションちゃんと設定できているかは、スレーブ側の`Read_Master_Log_Pos`の値がマスター側の`Position`の値と同じであるかどうかで確認します。

```mysql:masterステータス（マスター側）
mysql> show master status\G
*************************** 1. row ***************************
            File: db001-bin.000001
        Position: 520
    Binlog_Do_DB: 
Binlog_Ignore_DB: 
1 row in set (0.00 sec)
```

```mysql:slaveステータス（スレーブ側）
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 10.0.0.205
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: db001-bin.000001
          Read_Master_Log_Pos: 520
               Relay_Log_File: mysqld-relay-bin.000002
                Relay_Log_Pos: 253
        Relay_Master_Log_File: db001-bin.000001
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 520
              Relay_Log_Space: 410
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 205
1 row in set (0.00 sec)
```

あとは実際にマスター側でDBを作成したりして、それがスレーブへ反映されているかを確認するとより確実かもしれないです。

```mysql:repltest2作成（マスター側）
mysql> create database repltest2;
Query OK, 1 row affected (0.00 sec)
```

```mysql:作成確認（マスター側）
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| repltest           |
| repltest2          |
| test               |
+--------------------+
6 rows in set (0.00 sec)
```

```mysql:同期確認（スレーブ側）
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| repltest           |
| repltest2          |
| test               |
+--------------------+
6 rows in set (0.00 sec)
```


<br>
# おわりに
MySQLのレプリケーション設定は冗長化ではないので、そこは勘違いしないように要注意です。

