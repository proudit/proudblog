---
title: Zabbix監視で特定のアラートだけを通知OFFにする。
date: 2017-01-20
tags: zabbix
author: kohei
ogp:
  og: 'Zabbixの監視アラートで、一時的にアラートを停止したい場合ってありますよね？
例えばDiskアラートが発生した場合など、クリティカルでないので後で対処したい場合など。
そんな場合はトリガーを無効にすれば解決です。一応、備忘録も兼ねて方法を書いてみました。'
---

# はじめに
Zabbixの監視アラートで、一時的にアラートを停止したい場合ってありますよね？
例えばDiskアラートが発生した場合など、クリティカルでないので後で対処したい場合など。
そんな場合はトリガーを無効にすれば解決です。一応、備忘録も兼ねて方法を書いてみました。


<br>
# 方法
[設定] > [ホスト] をクリックします。
![zabbix01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/cca7a1bd-ca2e-652b-75f2-b2c4ca6d01d6.png)

<br>
[対象ホスト] > [トリガー] をクリックします。
![zabbix02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6c2d93cd-b9ff-c2c4-9445-07753382747b.png)

<br>
停止したいアラートのステータス欄の [有効] をクリックします。
![zabbix03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9bea4573-0d98-9f77-1b7e-517299f416da.png)

<br>
「トリガーを無効にしました」 が表示され、ステータスが [無効] になれば完了です。
![zabbix04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e09ead12-9202-d6af-013a-79650d6d8234.png)


<br>
# おわりに
Zabbixを普段使っている人であればなんでもない作業だと思います。
でも、普段触れていない人にしてみたら地味にわかりにくいかなと思います。トリガー、アイテムとか。。。

