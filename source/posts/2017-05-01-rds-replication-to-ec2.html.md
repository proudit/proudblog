---
title: Amazon RDS のレプリケーションをEC2で行う。
date: 2017-05-01
tags: AWS, RDS, MySQL
author: kohei
ogp:
  og: 'RDSのレプリケーションをEC2を使って行いました'
---

# はじめに
RDSのレプリケーションをEC2を使って行いました。
![rds-ec2_rep.png](https://qiita-image-store.s3.amazonaws.com/0/82090/dff5d22e-527d-0622-5bff-a8862b41aa0e.png)


<br>
# 設定
## 1. binlog_checksumの設定
まずは忘れないうちにパラメータグループの設定を行なってしまいましょう。マスターとなるRDSに対して行う設定です。
RDSにアタッチしてるパラメータグループの _binlog_checksum_ を _NONE_ に設定します。
![rds-binlog_checksum02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6ef73948-de09-6a54-68ed-5e46c3011673.png)

もし、これを設定していないで `start slave` を行うと、

```text:error
Got fatal error 1236 from master when reading data from binary log: 'Slave can not handle replication events with the checksum that master is configured to log; the first event 'mysql-bin-changelog.000008' at 422, the last event read from '/rdsdbdata/log/binlog/mysql-bin-changelog.000008' at 422, the last byte read from '/rdsdbdata/log/binlog/mysql-bin-changelog.000008' at 120.'
```
というエラーが発生します。


<br>
## 2. レプリケーション用アカウントの作成
パラメータグループの設定が完了したら、次はレプリケーション用のアカウントを作成します。

```mysql:アカウント作成
mysql> GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%' IDENTIFIED BY 'hogehoge';
Query OK, 0 rows affected (0.02 sec)
```


<br>
## 3. _rds_heartbeat2_の作成
ここからはスレーブとなるEC2のMySQLに対して行います。
EC2のmysqlデータベースにはもちろんrds関連のテーブルは存在しません。
そのため、 _rds_heartbeat2_ テーブルを作成しておきます。

```mysql:テーブル作成
mysql> CREATE TABLE `rds_heartbeat2` (`id` int(11) NOT NULL, `value` bigint(20) DEFAULT NULL, PRIMARY KEY (`id`)) ENGINE=InnoDB DEFAULT CHARSET=latin1;
Query OK, 0 rows affected (0.01 sec)
```

ここでテーブルを作成しておかないと _start slave_ した際に以下のようなエラーにが発生するので注意です。

```text:error
Error 'Table 'mysql.rds_heartbeat2' doesn't exist' on query. Default database: 'mysql'. Query: 'INSERT INTO mysql.rds_heartbeat2(id, value) values (1,1493274809584) ON DUPLICATE KEY UPDATE value = 1493274809584'
```


<br>
### 4. my.cnfの設定
次に、 _my.cnf_ の _[mysqld]_ に以下の設定を追加します。

```text:my.cnf
server-id=206
replicate-ignore-db=mysql
```

|オプション             |説明|
|:-------------------|:--|
|server-id           |マスターおよびスレーブサーバーが自身を識別するための一意の数字|
|replicate-ignore-db |無視するデータベースを指定|

_server-id_ の数字は任意のもので構いません。 _replicate-ignore-db_ でmysqlデータベースをレプリケーションの対象外としています。


ここで、 __「 _replicate-ignore-db_ で _mysql_ を除外しているから _rds_heartbeat2_ は作成しなくてもいいのでは？」__ と思いますが、ステートメントベースレプリケーションを利用する場合は予期した通りに機能しないという記載があります。

> [ー 引用：17.1.4.3 レプリケーションスレーブのオプションと変数](https://dev.mysql.com/doc/refman/5.6/ja/replication-options-slave.html)
ステートメントベースレプリケーションを使用する場合、次の例は予期したとおりに機能しません。スレーブが --replicate-ignore-db=sales で起動され、次のステートメントをマスターで発行するものとします。
>
```
USE prices;
UPDATE sales.january SET amount=amount+1000;
```
このような場合 UPDATE ステートメントは複製されます。--replicate-ignore-db が (USE ステートメントで指定された) デフォルトデータベースにのみ適用されるためです。sales データベースがステートメントで明示的に指定されたため、ステートメントはフィルタされませんでした。しかし、行ベースレプリケーションを使用するときは、UPDATE ステートメントの影響はスレーブに伝達されず、sales.january テーブルのスレーブのコピーは変更されません。この例では、sales データベースのマスターのコピー内のテーブルに加えられたすべての変更は、--replicate-ignore-db=sales によってスレーブで無視されます。

ここに記載されている内容だと、行ベースのレプリケーションに切り替えれば意図した通り除外できるようですが、そうなるとバイナリログの量が増加し、外部とのレプリケーションの場合だと通信料も増加するため注意が必要です。


<br>
# レプリケーション
## 1. RDSへのトラフィック停止
まずはRDSに対して流れるトラフィックを全て停止します。また、実行中のプロセスがないか確認もしておきましょう。
ある場合は各プロセスの _mysql.rds_kill_ コマンドを呼び出して、すべてのセッションを閉じます。

```mysql:プロセスチェック
mysql> show processlist;
+-------+----------+------------------+-------+---------+------+-------------+------------------+
| Id    | User     | Host             | db    | Command | Time | State       | Info             |
+-------+----------+------------------+-------+---------+------+-------------+------------------+
| 52605 | rdsadmin | localhost:26632  | mysql | Sleep   |   13 |             | NULL             |
| 94655 | awsuser  | 10.0.0.206:58658 | NULL  | Query   |    0 | System lock | show processlist |
+-------+----------+------------------+-------+---------+------+-------------+------------------+
2 rows in set (0.00 sec)
```


<br>
## 2. マスターポジション確認
そうしたら次はマスターの _binlog_ファイル名とポジションを確認します。

```mysql:MASTERステータスチェック
mysql> show master status;
+----------------------------+----------+--------------+------------------+-------------------+
| File                       | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+----------------------------+----------+--------------+------------------+-------------------+
| mysql-bin-changelog.000016 |      410 |              |                  |                   |
+----------------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)
```


<br>
## 3. データベースdump
確認ができたらレプリケーションするデータベースのdumpを行います。

```bash:mysqldump
$ mysqldump -hrds001.cs8xkvdfl8ru.ap-northeast-1.rds.amazonaws.com --databases rds001 -uawsuser -pmypassword --single-transaction --routines > rds001.dump
```


<br>
## 4. リストア
dumpが完了したらスレーブ(EC2)へリストアします。

```bash:リストア
$ mysql -uroot -p < rds001.dump 
```


<br>
## 5. 読み取り位置の指定
リストアが完了したら先ほどのMASTERステータスで確認した値を元に、`CHANGE MASTER TO`でスレーブサーバーがマスターサーバーへ接続する際のバイナリログ読み取り位置を指定します。

```mysql:
mysql> change master to MASTER_HOST='rds001.cs8xkvdfl8ru.ap-northeast-1.rds.amazonaws.com', MASTER_USER='repl', MASTER_PASSWORD='hogehoge', MASTER_LOG_FILE='mysql-bin-changelog.000024', MASTER_LOG_POS=120;
Query OK, 0 rows affected (0.02 sec)
```

`CHANGE MASTER TO`でしたら`SHOW SLAVE STATUS`で設定内容を確認しておきましょう。

```
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: 
                  Master_Host: rds001.cs8xkvdfl8ru.ap-northeast-1.rds.amazonaws.com
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin-changelog.000024
          Read_Master_Log_Pos: 120
               Relay_Log_File: mysqld-relay-bin.000001
                Relay_Log_Pos: 4
        Relay_Master_Log_File: mysql-bin-changelog.000024
             Slave_IO_Running: No
            Slave_SQL_Running: No
              Replicate_Do_DB: 
          Replicate_Ignore_DB: information_schema,performance_schema,mysql
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 120
              Relay_Log_Space: 107
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
1 row in set (0.00 sec)
```


<br>
## 6. レプリケーションの開始
設定に問題なければ`START SLAVE`でレプリケーションを開始します。

```mysql:SLAVEスタート
mysql> start slave;
Query OK, 0 rows affected (0.00 sec)
```

スタートができたらステータスをもう一度確認してみます。

```mysql:SLAVEステータスチェック
mysql> show slave status\G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 10.0.2.150
                  Master_User: repl
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin-changelog.000024
          Read_Master_Log_Pos: 120
               Relay_Log_File: mysqld-relay-bin.000002
                Relay_Log_Pos: 276
        Relay_Master_Log_File: mysql-bin-changelog.000024
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB: 
          Replicate_Ignore_DB: information_schema,performance_schema,mysql
           Replicate_Do_Table: 
       Replicate_Ignore_Table: 
      Replicate_Wild_Do_Table: 
  Replicate_Wild_Ignore_Table: 
                   Last_Errno: 0
                   Last_Error: 
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 120
              Relay_Log_Space: 433
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

_Slave_IO_Running_ と _Slave_SQL_Running_ が _Yes_ になっていれば完了です。



<br>
# おわりに
RDSを使うのであればリードレプリカを利用するのが一番です。ですが、リードレプリカの料金も標準のインスタンスと同じなので、EC2と比べると費用がかかってしまいます。そういった場合にはこういう方法もありなのかもしれないです。
また、移行の際なども切り戻しを想定した場合はこの構成が必要ですね。

