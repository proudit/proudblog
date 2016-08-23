---
title: 第４回 AWSとIDCFをVPN接続する - 最後の仕上げ編
date: 2016-05-26
tags: IDCFクラウド, AWS, VPN
author: kohei
---

# はじめに
---
[<< 前回：第３回 AWSとIDCFをVPN接続する - VPN接続編（全４回）](http://qiita.com/kooohei/items/f16dcb9e7280b29deee7)
IDCFクラウドにVyOSで仮想マシンを作成して、IDCFクラウドとAWSをVPNで接続する設定を説明します。
![idcf-vpn-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9b15d672-f654-ab05-fb61-57cf8951b58e.png)

前回でIDCFのVPNゲートウェイにAWSで取得したコンフィグを流し込み、ついにIDCFとAWS間のVPN接続が完了しました。
![idcf-vpn-7.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b290de8c-a844-3286-22e6-3e305e593004.png)

とはいえ、このままではただVPN接続しただけで、サーバー間で通信を行うことはできません。

そこで仕上げとして、サーバー間で通信ができるようにルーティングとセキュリティグループの設定を行います。


<br>
# ルーティング設定
---
## AWS
![idcf-vpn-5.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f143d7a0-9cf1-f292-da00-0cea9741299c.png)

ここで必要なのは「ルートテーブル」と「セキュリティグループ」の２点です。
<br>
・ルートテーブル
作成した「VPN接続」の「要約」タブの内容が表示されていることを確認し「VPC」をクリックします。
![idcf-vpn_4_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/422d6f5e-bd8f-54f5-f59a-c1cb4a8cd7c1.png)

<br>
対象の「VPC」の「概要」タブを表示し「ルートテーブル」をクリックします。
![idcf-vpn_4_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/31fbb0e9-5aba-10ad-eb67-847d8b2fc0a9.png)

<br>
対象の「ルートテーブル」の「ルート」の内容を「編集」してルーティングを追加します。

```text:追加ルート
10.13.0.0/21     vgw-adsfad（仮想プライベートゲートウェイ）
```
※サブネットで別のルートテーブルも利用している場合はそちらを追加する必要があるかもしれないので注意が必要です。

![idcf-vpn_4_03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1b79aa29-30a6-d660-0a7a-f198453d97da.png)

<br>
・セキュリティグループの設定
インスタンスに紐付いているセキュリティグループに対象となるIDCF側のNWを追加します。

```tex:ルートテーブル
    タイプ        プロトコル  ポート範囲   送信元
すべてのトラフィック    すべて    すべて   10.13.0.0 
```

<br>
<br>
## IDCF
![idcf-vpn-6.png](https://qiita-image-store.s3.amazonaws.com/0/82090/5da656ec-d04e-2357-0f3f-2d4df62c3d5b.png)

IDCFではAWSのようなルートテーブルなどのルーティングを一括管理するものがないので各サーバに対しスタティックルートの設定を行う必要があります。

<br>
・スタティックルートの設定
サーバへログインします。

```bash:コマンド例
$ ssh hogehoge@xxx.xxx.xxx.xxx
```

<br>
ルーティングを追加します。

```bash:コマンド
$ sudo route add -net 172.31.0.0 gw 10.13.0.2 netmask 255.255.0.0
```
今回はコマンドによる一時的な追加ですが、永久的に追加するのであればstatic-routesに直接記載します。(Ubuntuの場合)

```text:/etc/network/if-up.d/static-routes
#!/bin/sh
/sbin/route add -net 172.31.0.0 gw 10.13.0.2 netmask 255.255.0.0 dev eth0
```
また、実行権限が必要なのでお忘れなく。

```bash:コマンド
$ sudo chmod +x /etc/network/if-up.d/static-routes
```

<br>
# 確認
---
それでは疎通ができたかpingで確認してみましょう。

<br>
## AWS環境から確認
それではAWS環境にあるサーバにログインしてください。

まずは、ルーティングの確認です。

```bash:コマンド
$ netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.20.0.1       0.0.0.0         UG        0 0          0 eth0
172.31.0.0       0.0.0.0         255.255.0.0   U         0 0          0 eth0
```
とは言ってもAWSの場合はルートテーブルで管理してますので`netstat`では確認できません。
ということでとりあえず疎通確認します。

```bash:コマンド
$ ping xxx.xxx.xxx.xxx
PING xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx) 56(84) bytes of data.
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=1 ttl=63 time=11.1 ms
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=2 ttl=63 time=12.7 ms
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=3 ttl=63 time=10.4 ms
```
無事、確認できました。

<br>
## IDCF環境から確認
まずはルーティングの確認です。

```bash:コマンド
$ netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.13.0.1       0.0.0.0         UG        0 0          0 eth0
10.13.0.0       0.0.0.0         255.255.248.0   U         0 0          0 eth0
xxx.xxx.xxx.xxx <VyOSのIP>      255.255.0.0     UG        0 0          0 eth0
```

こちらはルーティングが確認できました。(まぁ、さっき追加したので当たり前ですねw)
ということで疎通確認しましょう。

```bash:コマンド
$ ping xxx.xxx.xxx.xxx
PING xxx.xxx.xxx.xxx (xxx.xxx.xxx.xxx) 56(84) bytes of data.
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=1 ttl=63 time=11.1 ms
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=2 ttl=63 time=12.7 ms
64 bytes from xxx.xxx.xxx.xxx: icmp_seq=3 ttl=63 time=10.4 ms
```
こちらも無事、確認できました。


<br>
# おわりに
---
以上で今回はAWSの対向の環境はIDCFですが、VPN接続するために利用しているのはVyOSです。
なので、その他の環境であっても同様の設定(ポート許可など)ができればVyOSを利用してVPN接続が可能です。

