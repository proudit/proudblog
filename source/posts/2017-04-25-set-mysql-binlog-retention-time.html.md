---
title: Amazon RDSのMySQLバイナリログ保持時間を設定する。
date: 2017-04-25
tags: AWS, RDS, MySQL
author: kohei
ogp:
  og: ''
---

# はじめに
Amazon RDS では、 _[mysql.rds_set_configuration](http://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/mysql_rds_set_configuration.html)_ ストアドプロシージャを使用してバイナリログの保持時間を指定することができます。

# 設定
それでは保持時間について確認してみます。

```mysql:保持時間確認
mysql> call mysql.rds_show_configuration;
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| name                   | value | description                                                                                          |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| binlog retention hours | NULL  | binlog retention hours specifies the duration in hours before binary logs are automatically deleted. |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)
```
デフォルト値は _NULL(バイナリログを保持しない)となっています。
これを24時間に変更します。

```mysql:保持時間変更(NULL→24)
mysql> call mysql.rds_set_configuration('binlog retention hours', 24);
Query OK, 0 rows affected (0.06 sec)
```
変更できたらもう一度確認してみます。

```mysql:保持時間確認
mysql> call mysql.rds_show_configuration;
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| name                   | value | description                                                                                          |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| binlog retention hours | 24    | binlog retention hours specifies the duration in hours before binary logs are automatically deleted. |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)
```
24時間に変更されました。

デフォルト値に戻すにはNULLを与えればOKです。

```mysql:保持時間変更(24→NULL)
mysql> call mysql.rds_set_configuration('binlog retention hours', NULL);
Query OK, 0 rows affected (0.00 sec)
```

```mysql:保持時間確認
mysql> call mysql.rds_show_configuration;
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| name                   | value | description                                                                                          |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
| binlog retention hours | NULL  | binlog retention hours specifies the duration in hours before binary logs are automatically deleted. |
+------------------------+-------+------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)

Query OK, 0 rows affected (0.00 sec)
```
デフォルト値に変更されました。


# 注意事項
- _binlog retention hours_ の最大値はMySQLの場合は168時間(7日)、Amazon Aurora DBの場合は720時間(30日)です。
- 利用可能なMySQLのバージョンは5.6および5.7です。(2017年4月25日現在)


# おわりに
バイナリログの保持期間を設定した場合、バイナリログに必要以上の容量を使用されないよう、ストレージ使用状況をモニタリングするようにしましょう。

