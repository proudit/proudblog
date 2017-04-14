---
title: Amazon RDS のエラーログをCLIで取得する。
date: 2017-04-14
tags: RDS, AWS
author: kohei
ogp:
  og: 'Amazon RDS for MySQ においてエラーログを取得したいと思います。'
---

# はじめに
**Amazon RDS for MySQL** においてエラーログを取得したいと思います。
一般ログとスローログに関してはテーブルへ出力させることができるため、*mysql*コマンドでも取得できるようになります。ですがエラーログはできないみたいです。
[MySQL エラーログにアクセスする](http://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/USER_LogAccess.Concepts.MySQL.html)
なので**AWS CLI**を利用することで取得したいと思います。


<br>
# ログファイルの確認
まずはログを確認します。RDSのログを確認するには [**describe-db-log-files**](http://docs.aws.amazon.com/cli/latest/reference/rds/describe-db-log-files.html) を使います。

```bash:ログファイル一覧
$ aws rds describe-db-log-files --db-instance-identifier rds001
{
    "DescribeDBLogFiles": [
        {
            "LastWritten": 1491455703000, 
            "LogFileName": "error/mysql-error-running.log", 
            "Size": 19425
        }, 
        {
            "LastWritten": 1491436546000, 
            "LogFileName": "error/mysql-error-running.log.0", 
            "Size": 63825
        }, 
        {
            "LastWritten": 1491440100000, 
            "LogFileName": "error/mysql-error-running.log.1", 
            "Size": 62255
...
```

ですが、JSON形式だと見づらいのですね。 *--filename-contains error* とすることで *error* ログのみを抽出することができ、さらに *--output text* で一覧表示させることができます。

```bash:エラーログ一覧
$ aws rds describe-db-log-files --db-instance-identifier rds001 --filename-contains error --output text
DESCRIBEDBLOGFILES	1491469200000	error/mysql-error-running.log	0
DESCRIBEDBLOGFILES	1491436546000	error/mysql-error-running.log.0	63825
DESCRIBEDBLOGFILES	1491440100000	error/mysql-error-running.log.1	62255
DESCRIBEDBLOGFILES	1491404111000	error/mysql-error-running.log.15	72150
DESCRIBEDBLOGFILES	1491407728000	error/mysql-error-running.log.16	72150
DESCRIBEDBLOGFILES	1491411306000	error/mysql-error-running.log.17	70300
DESCRIBEDBLOGFILES	1491414901000	error/mysql-error-running.log.18	71225
DESCRIBEDBLOGFILES	1491418516000	error/mysql-error-running.log.19	68450
DESCRIBEDBLOGFILES	1491443708000	error/mysql-error-running.log.2	62620
DESCRIBEDBLOGFILES	1491422125000	error/mysql-error-running.log.20	67525
DESCRIBEDBLOGFILES	1491425715000	error/mysql-error-running.log.21	65675
DESCRIBEDBLOGFILES	1491429300000	error/mysql-error-running.log.22	65675
DESCRIBEDBLOGFILES	1491432938000	error/mysql-error-running.log.23	65675
DESCRIBEDBLOGFILES	1491447334000	error/mysql-error-running.log.3	61050
DESCRIBEDBLOGFILES	1491450949000	error/mysql-error-running.log.4	61050
DESCRIBEDBLOGFILES	1491454500000	error/mysql-error-running.log.5	59200
DESCRIBEDBLOGFILES	1491458107000	error/mysql-error-running.log.6	59200
DESCRIBEDBLOGFILES	1491461705000	error/mysql-error-running.log.7	58275
DESCRIBEDBLOGFILES	1491465304000	error/mysql-error-running.log.8	56425
DESCRIBEDBLOGFILES	1491468300000	error/mysql-error-running.log.9	45012
DESCRIBEDBLOGFILES	1491491100000	error/mysql-error.log	0
```
エラーログは *mysql-error-running.log* という名前で１時間ごとに出力されます。


<br>
# エラーログの取得
では実際にエラーログの中身を見て見ます。
エラーログは [**download-db-log-file-portion**](http://docs.aws.amazon.com/cli/latest/reference/rds/download-db-log-file-portion.html) コマンドを使います。

```bash:エラーログ
$ aws rds download-db-log-file-portion --db-instance-identifier rds001 --log-file-name error/mysql-error-running.log.6
```
ここでも *--output text* として通常のログと同じように出力させたいと思います。


```bash:エラーログ
$ aws rds download-db-log-file-portion --db-instance-identifier rds001 --log-file-name error/mysql-error-running.log.6 --output text
2017-04-06 04:55:08 3372 [Note] Error reading relay log event: slave SQL thread was killed
2017-04-06 04:55:08 3372 [Note] Slave I/O thread killed while connecting to master
2017-04-06 04:55:08 3372 [Note] Slave I/O thread exiting, read up to log 'db001-bin.000002', position 353
2017-04-06 04:55:09 3372 [Warning] Storing MySQL user name or password information in the master info repository is not secure and is therefore not recommended. Please consider using the USER and PASSWORD connection options for START SLAVE; see the 'START SLAVE Syntax' in the MySQL Manual for more information.
2017-04-06 04:55:09 3372 [ERROR] Slave I/O: error connecting to master 'repl@10.0.0.205:3306' - retry-time: 60  retries: 1, Error_code: 2003
2017-04-06 04:55:09 3372 [Note] Slave SQL thread initialized, starting replication in log 'db001-bin.000002' at position 353, relay log '/rdsdbdata/log/relaylog/relaylog.001308' position: 236
...
```
これでエラーログの確認ができました。


<br>
# ログについて
- エラーログは *mysql-error.log* ファイルへ書き込まれる。
- *mysql-error.log*は5分ごとにフラッシュされる。
- フラッシュされた内容は *mysql-error-running.log* へ追加される。
- *mysql-error-running.log* は１時間ごとにローテーションされる。
- ローテーションされたログは24時間保持される。
- 各ログファイルはUTC時間がファイル名に付加される。(ローテーションされたUTC時刻の%H)
- エラーログへの書き込みは 「起動時」、「シャットダウン時」、「エラー検出時」にのみ行われる。


<br>
# ポリシー
CLIで取得する際のポリシーです。

```json:policy
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1491493558000",
            "Effect": "Allow",
            "Action": [
                "rds:DescribeDBLogFiles",
                "rds:DownloadCompleteDBLogFile",
                "rds:DownloadDBLogFilePortion"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```
|Actions|Description|
|:--|:--|
|[DescribeDBLogFiles](http://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/APIReference/API_DescribeDBLogFiles.html)|DBインスタンスのログをリストする。|
|[DownloadCompleteDBLogFile](http://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/RESTReference.html#RESTReference.DownloadCompleteDBLogFile)|指定したデータベースログファイルの内容をダウンロードする。|
|[DownloadDBLogFilePortion](http://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/APIReference/API_DownloadDBLogFilePortion.html)|指定されたログファイルの全部または一部をダウンロードする（最大1 MBのサイズ）。|


<br>
# おわりに
CLIを利用するとエラーログも取得できるようになります。ですが、やっぱりスローログや一般ログと同じようにtableへ出力できるようになって欲しいですね。。。

