---
title: Amazon RDS の外部で実行される MySQLとのレプリケーション
date: 2017-03-31
tags: MySQL, RDS, AWS
author: kohei
ogp:
  og: 'Amazon RDS は外部のMySQLとレプリケーションを組むことができます'
---

# はじめに
Amazon RDS は外部のMySQLとレプリケーションを組むことができます。

![replication.png](https://qiita-image-store.s3.amazonaws.com/0/82090/28e920c6-a1e0-dd82-1eed-5ddf7a5077a5.png)


<br>
# 事前設定
## ユーザー作成
1.まずはマスターとなる外部MySQLにレプリケーションするためのユーザーを作成します。

```mysql:ユーザー作成
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'hogehoge';
```

<br>
## パラメータ設定
1.次にパラメータの設定を行うために *my.cnf* の *[mysqld]* に以下のパラメータを設定します。

```text:mysqld
log-bin=db001-bin
server-id=205
```

<br>
2.設定したらmysqlを再起動して反映します。

```bash:mysql再起動
$ sudo /etc/init.d/mysqld restart
Stopping mysqld:                                           [  OK  ]
Starting mysqld:                                           [  OK  ]
```

以上で事前設定は完了です。


<br>
# レプリケーション
## マスター作業
1.まずはマスターとなるMySQLをロックします。

```mysql:ロック
mysql> FLUSH TABLES WITH READ LOCK;
```

この状態だとmysqlから抜けると解除されてしまうので、読み取り専用にしてしまった方が安全です。

```mysql:読み取り専用
mysql> SET GLOBAL read_only = ON;
```

<br>
2.ロックしたらbinファイルとポジションを確認します。(後でRDSに設定する際に必要になります。)

```mysql:マスターステータス確認
mysql> SHOW MASTER STATUS\G
*************************** 1. row ***************************
            File: db001-bin.000002
        Position: 107
    Binlog_Do_DB: 
Binlog_Ignore_DB: 
1 row in set (0.00 sec)
```

<br>
3.ダンプしたらロックを解除しておきましょう。

```mysql:ロック解除
mysql> SET GLOBAL read_only = OFF;
mysql> UNLOCK TABLES; 
```


<br>
4.マスターからデータをdumpします。

```bash:dump
$ mysqldump --databases repltest -u root -phogehoge --master-data --single-transaction > db001.dump
```

<br>
## スレーブ作業
1.ダンプしたらスレーブとなるRDSへリストアです。

```mysql:RDSアクセス
$ mysql -hrds001.cs8xkvdfl8ru.ap-northeast-1.rds.amazonaws.com -uawsuser -pmypassword
```

```mysql:リストア
mysql> source db001.dump
```

<br>
2.[mysql.rds_set_external_master](http://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/mysql_rds_set_external_master.html) コマンドを使用して、外部の MySQL データベースをレプリケーションマスターとして指定します。

```mysql:rds_set_external_master
mysql> CALL mysql.rds_set_external_master ('10.0.0.205', 3306, 'repl', 'hogehoge', 'db001-bin.000002', 107, 0); 
Query OK, 0 rows affected (0.08 sec)
```

参考までに指定するステータスは以下の様になります。

```mysql:ステータス確認
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: 10.0.0.205
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: db001-bin.000002
          Read_Master_Log_Pos: 107
               Relay_Log_File: relaylog.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: db001-bin.000002
             Slave_IO_Running: No
            Slave_SQL_Running: No
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: mysql.plugin,mysql.rds_monitor,mysql.rds_sysinfo,mysql.rds_replication_status,mysql.rds_history,innodb_memcache.config_options,innodb_memcache.cache_policies
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 107
              Relay_Log_Space: 120
              Until_Condition: None
               Until_Log_File: 
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File: 
           Master_SSL_CA_Path: 
              Master_SSL_Cert: 
            Master_SSL_Cipher: 
               Master_SSL_Key: 
        Seconds_Behind_Master: NULL
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error: 
               Last_SQL_Errno: 0
               Last_SQL_Error: 
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 0
                  Master_UUID: 
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: 
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
1 row in set (0.00 sec)
```

<br>
3.[mysql.rds_start_replication](http://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/mysql_rds_start_replication.html) コマンドでレプリケーションを開始します。

```mysql:レプリケーション開始
mysql> CALL mysql.rds_start_replication;
+-------------------------+
| Message                 |
+-------------------------+
| Slave running normally. |
+-------------------------+
1 row in set (1.01 sec)

Query OK, 0 rows affected (1.01 sec)
```

*Slave_IO_Running* と *Slave_SQL_Running* が**Yes**なのでレプリケーションされているのが確認できました。

```mysql:ステータス確認
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 10.0.0.205
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: db001-bin.000002
          Read_Master_Log_Pos: 256
               Relay_Log_File: relaylog.000004
                Relay_Log_Pos: 419
        Relay_Master_Log_File: db001-bin.000002
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: 
           Replicate_Do_Table: 
       Replicate_Ignore_Table: mysql.plugin,mysql.rds_monitor,mysql.rds_sysinfo,mysql.rds_replication_status,mysql.rds_history,innodb_memcache.config_options,innodb_memcache.cache_policies
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 256
              Relay_Log_Space: 917
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
                  Master_UUID: 
             Master_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
      Slave_SQL_Running_State: Slave has read all relay log; waiting for the slave I/O thread to update it
           Master_Retry_Count: 86400
                  Master_Bind: 
      Last_IO_Error_Timestamp: 
     Last_SQL_Error_Timestamp: 
               Master_SSL_Crl: 
           Master_SSL_Crlpath: 
           Retrieved_Gtid_Set: 
            Executed_Gtid_Set: 
                Auto_Position: 0
1 row in set (0.00 sec)
```

<br>
# 確認
実際にマスターに何かを書き込んでみて、それがスレーブへ反映されているか確認しましょう。

1.とりあえず、ここでは新たに*repltestrds*データベースを作成しています。

```mysql:マスター
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
6 rows in set (0.00 sec)

mysql> create database repltestrds;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| repltest           |
| repltestrds        |
| test               |
+--------------------+
7 rows in set (0.00 sec)
```

<br>
2.作成できたらスレーブへの反映を確認してみます。

```mysql:スレーブ
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| innodb             |
| mysql              |
| performance_schema |
| repltest           |
| repltestrds        |
| sys                |
+--------------------+
7 rows in set (0.00 sec)
```

反映されているのが確認できました。


<br>
# おわりに
どうせならマスターをRDSにすると思うので、通常はRDSを外部MySQLのレプリケーションにする機会は少ないかもしれません。他の環境からAWSへ移行するときくらいでしょうか？
ですが、どうしてもマスターを外部MySQLにしないとダメな場合はこの様なやり方で組むことができます。



