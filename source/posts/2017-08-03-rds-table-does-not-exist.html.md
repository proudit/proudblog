---
title: "Error 'Table 'mysql.rds_heartbeat2' doesn't exist' on query. Default database: 'mysql'. Query: 'INSERT INTO mysql.rds_heartbeat2(id, value) values (1,1493274809584) ON DUPLICATE KEY UPDATE value = 1493274809584'"
date: 2017-08-03
tags: AWS, RDS
author: kohei
ogp:
  og: 'RDS → EC2(MySQL)のレプリケーションを組んでいたところ、突然レプリケーションがスト
ップしてしまいました'
---

# はじめに
RDS → EC2(MySQL)のレプリケーションを組んでいたところ、突然レプリケーションがストップしてしまいました。

```mysql:ステータス
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: rds001.cs8xkvdfl8ru.ap-northeast-1.rds.amazonaws.com
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin-changelog.009536
          Read_Master_Log_Pos: 491
               Relay_Log_File: mysqld-relay-bin.000004
                Relay_Log_Pos: 357
        Relay_Master_Log_File: mysql-bin-changelog.009536
             Slave_IO_Running: Yes
            Slave_SQL_Running: No
              Replicate_Do_DB: 
          Replicate_Ignore_DB: mysql,hogehoge
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 1146
                   Last_Error: Error 'Table 'mysql.rds_heartbeat2' doesn't exist' on query. Default database: 'mysql'. Query: 'INSERT INTO mysql.rds_heartbeat2(id, value) values (1,1496119904584) ON DUPLICATE KEY UPDATE value = 1496119904584'
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 201
              Relay_Log_Space: 857
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
               Last_SQL_Errno: 1146
               Last_SQL_Error: Error 'Table 'mysql.rds_heartbeat2' doesn't exist' on query. Default database: 'mysql'. Query: 'INSERT INTO mysql.rds_heartbeat2(id, value) values (1,1496119904584) ON DUPLICATE KEY UPDATE value = 1496119904584'
  Replicate_Ignore_Server_Ids: 
             Master_Server_Id: 1505545156
1 row in set (0.00 sec)
```

エラー内容は以下です。

```text:エラー
Error 'Table 'mysql.rds_heartbeat2' doesn't exist' on query. Default database: 'mysql'. Query: 'INSERT INTO mysql.rds_heartbeat2(id, value) values (1,1493274809584) ON DUPLICATE KEY UPDATE value = 1493274809584'
```

<br>
# 原因
replicate-ignore-db オプションによる除外対象を指定していますが、レプリケーションのデフォルト設定であるステートメントベースの場合は USE 文で選択された操作に対して行われます。
今回の場合はmysql.rds_heartbeat2 というデータベース名とテーブル名を DML 文の中で直接指定していたため、replicate-ignore-db オプションで mysql データベースを除外対象としてもレプリケーション対象になってしまいました。


<br>
# 対処法
今回の場合は該当のテーブルを作成してあげるだけで可能です。

```mysql:レプリケーション停止
mysql> stop slave;
Query OK, 0 rows affected (0.00 sec)
```

```mysql:テーブル作成
mysql> CREATE TABLE mysql.rds_heartbeat2 ( `id` int(11) NOT NULL, `value` bigint(20) DEFAULT NULL, PRIMARY KEY (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
Query OK, 0 rows affected (0.00 sec)
```

```mysql:レプリケーション開始
mysql> start slave;
Query OK, 0 rows affected (0.00 sec)
```

```mysql:ステータス
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: rds001.cs8xkvdfl8ru.ap-northeast-1.rds.amazonaws.com
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin-changelog.009536
          Read_Master_Log_Pos: 491
               Relay_Log_File: mysqld-relay-bin.000005
                Relay_Log_Pos: 276
        Relay_Master_Log_File: mysql-bin-changelog.009536
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: mysql,hogehoge
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 491
              Relay_Log_Space: 973
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
             Master_Server_Id: 1505545156
1 row in set (0.00 sec)
```


<br>
# おわりに
ここでは ```rdsrds_heartbeat2``` のテーブルでしたが、基本的にはRDSのレプリケーションをRDS以外で組む場合は RDS特有のテーブルは事前に作成してあげる必要があるので注意です。
