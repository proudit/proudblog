---
title: vnstatで手軽にtrafiicをモニタリング
date: 2016-03-08
tags: Linux,vnstat,vnstati 
author: kohei
---

# はじめに
---
vnstatはコマンドベースのネットワークtrafficモニターです。
trafficというとcactiとかmrtgといったのが最初に思い浮かぶと思いますが、それだとわざわざWebサーバを立てなくてはいけません。
もっと手軽に導入できるのがvnstatです。
また、時間別や日別など、様々なパターンでモニタリングができます。

<br>
# 1.インストール
---
ということでまず、インストール。

今回利用するサーバはAmazon Linuxです。

```bash:インストール(redhat系)
$ sudo yum install --enablerepo=epel vnstat
```

redhat系のインストールはepelリポジトリからyumインストールで可能ですが、ubuntu系はaptで以下の方法でインストールできます。

```bash:インストール(ubuntu系)
$ sudo apt-get install vnstat vnstati
```

また、vnstatに関する設定は*/etc/vnstat.conf*に記載され、データの保存場所やdata保存間隔などが設定できます。

<br>
# 2.コマンド実行
---
それではコマンドを実行してみましょう。

```bash:コマンド
$ vnstat
No database found, nothing to do. Use --help for help.

A new database can be created with the following command:
vnstat -u -i eth0

Replace 'eth0' with the interface that should be monitored.

The following interfaces are currently available:
eth0 lo
```

_“No database found …”_と表示されました。
インストールしたてで「まだデータベースが何もないよ！」と言っているみたいです。
続きを読むと_”vnstat -u -i eth0”_でデータベースが作成できると書いてあります。
ということで、作成してみます。

<br>
## 2.1. DB作成
```bash:DB作成
$ vnstat -u -i eth0
Error: Unable to read database "/var/lib/vnstat/eth0".
Info: -> A new database has been created.
```

一行目には”Error”とありますが、二行目には”Info”でデータベースが作成されたと記載があります。
これでデータベースが新規に作成されました。

```bash:確認
$ ls /var/lib/vnstat/
eth0
```

ということで再度コマンドを実行します。

```bash:実行
$ vnstat
eth0: Not enough data available yet.
```

まだ有効なデータがないと言われてしまいました。

<br>
## 2.2 データの更新
ということで、データを更新します。

```bash:データ取得
$ vnstat -u -i eth0
```

<br>
## 2.3 データの確認
では改めて確認してみましょう。

```bash:実行
$ vnstat
Database updated: Tue Jul 7 15:16:40 2015

eth0 since 07/07/15

rx: 25 KiB tx: 13 KiB total: 38 KiB

monthly
rx | tx | total | avg. rate
------------------------+-------------+-------------+---------------
Jul '15 25 KiB | 13 KiB | 38 KiB | 0.00 kbit/s
------------------------+-------------+-------------+---------------
estimated -- | -- | -- |

daily
rx | tx | total | avg. rate
------------------------+-------------+-------------+---------------
today 25 KiB | 13 KiB | 38 KiB | 0.01 kbit/s
------------------------+-------------+-------------+---------------
estimated -- | -- | -- |
```

デフォルトだと_monthly_と_daily_の2種類が表示されますが、オプションによって_weekly_表示にすることも可能です。

```bash:weekly表示
$ vnstat -w

eth0 / weekly

rx | tx | total | avg. rate
---------------------------+-------------+-------------+---------------
last 7 days 25 KiB | 13 KiB | 38 KiB | 0.00 kbit/s
current week 25 KiB | 13 KiB | 38 KiB | 0.00 kbit/s
---------------------------+-------------+-------------+---------------
estimated -- | -- | -- |
```

<br>
## 2.4. オプションの確認 
どのような出力方法が可能かは、”--help”オプションで確認ができます。

```bash:hellpオプション
$ vnstat --help
vnStat 1.11 by Teemu Toivola <tst at iki dot fi>

-q, --query query database
-h, --hours show hours
-d, --days show days
-m, --months show months
-w, --weeks show weeks
-t, --top10 show top10
-s, --short use short output
-u, --update update database
-i, --iface select interface (default: eth0)
-?, --help short help
-v, --version show version
-tr, --traffic calculate traffic
-ru, --rateunit swap configured rate unit
-l, --live show transfer rate in real time

See also "--longhelp" for complete options list and "man vnstat".
```

<br>
## 2.5. 自動取得設定(daemonの起動)
また、この_vnstat_は_daemon_が用意されているので、起動するだけで自動で情報が取得できます。

```bash:デーモン起動
$ sudo service vnstat start
vnstatd を起動中: [ OK ]
```

<br>
# 3.グラフの作成
---
また、_vnstati_で取得したデータからpngのグラフも作成できます。
rx：受信
tx：送信

<br>
### [月別(-m)]
![20160121_monthly.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d2a7989b-8f62-4b63-8024-2ce3bbb9b7e4.png)

```bash:コマンド
$ vnstati -m -o ./monthly.png
```

<br>
### [日別(-d)]
![20160121_daily.png](https://qiita-image-store.s3.amazonaws.com/0/82090/877feab1-5f7e-d49f-df81-1c3d5e6d1331.png)

```bash:コマンド
$ vnstati -d -o ./daily.png
```

<br>
### [時間別(-h)]
![20160121_hourly.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0ce83c1b-8f71-d524-bf1c-92793bc9de7a.png)

```bash:コマンド
$ vnstati -h -o ./houly.png
```

<br>
### [時間別サマリ(-vs)]
![20160121_hsum.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e361b0b8-e3a9-958b-e086-eb2dd93c94d8.png)

```bash:コマンド
$ vnstati -vs -o ./hsum.png
```

以上のように、気軽に導入できグラフ化も可能なのがとても便利です。

