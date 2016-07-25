---
title: 静的ルーティングの設定 - Linux
date: 2016-07-25
tags: Linux,Ubuntu,CentOS
author: kohei
ogp:
  og:
    description: 'AWSではルートテーブルがあるので設定することはないですが、そう言ったルーティングを管理する機能がない場合は自分で設定を行わなければなりません。
ということでルーティングの設定についてまとめてみました。'
---

# はじめに
AWSではルートテーブルがあるので設定することはないですが、そう言ったルーティングを管理する機能がない場合は自分で設定を行わなければなりません。
ということでルーティングの設定についてまとめてみました。

<br>
# 事前確認
とりあえず`netstat`コマンドで現在のルーティングの状態を確認しておきます。

```bash:コマンド
$ netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.13.0.1       0.0.0.0         UG        0 0          0 eth0
10.13.0.0       0.0.0.0         255.255.248.0   U         0 0          0 eth0
```

<br>
# ルーティングの追加
ルーティングの追加には一時的または永続的の２通りあります。コマンドでの追加、設定ファイルへ記載しての追加です。

<br>
## 一時的な追加
一時的な追加はコマンドでの追加となります。ここでは`route`コマンドと`ip`コマンドの２通りを紹介します。

<br>
### routeコマンド

#### ・networkの追加

```bash:コマンド
$ sudo route add -net 172.31.0.0 gw 10.13.0.145 netmask 255.255.0.0 eth0
```

#### ・hostの追加

```bash:コマンド
$ sudo route add -host 172.31.0.10 gw 10.13.0.145 eth0
```

_network_に比べて_host_は`-net`が`-host`になるのと、`netmask`が不要になります。
また、`eth0` は無くても大丈夫です。その場合は任意でルーティングが設定できる_eth_で設定されます。


<br>
### ipコマンド

##### ・networkの追加

```bash:コマンド
$ sudo ip route add 172.31.0.0/16 via 10.13.0.145 dev eth0
```

##### ・hostの追加

```bash:コマンド
$ sudo ip route add 172.31.0.10/32 via 10.13.0.145 dev eth0
```

ここでの_network_と_host_の違いは_netmask_だけです。_host_の場合は`/32`にするだけです。


<br>
## 永続的な追加

コマンドで一時的に追加しただけではサーバー再起動などをしてしまうと消えてしまいます。
そこで再起動してもルーティングが消えない設定を紹介します。

<br>
### Ubuntu の場合

#### ・その１
ひとつ目は`/etc/network/if-up.d/static-routes`で設定する方法です。

```bash:コマンド
$ sudo vi /etc/network/if-up.d/static-routes
```

```text:/etc/network/if-up.d/static-routes
#!/bin/sh
/sbin/route add -net 172.31.0.0 gw 10.13.0.145 netmask 255.255.0.0 dev eth0 // networkの場合
/sbin/route add -host 172.31.0.10 gw 10.13.0.145 eth0 // hostの場合
```

```bash:コマンド
$ sudo chmod +x /etc/network/if-up.d/static-routes
```

```bash:コマンド
$ sudo /etc/network/if-up.d/static-routes
```

#### ・その２
もう一つの方法は`/etc/network/interfaces`に設定する方法です。
`post-up`を使うと任意のコマンドが実行できるようになります。

```text:ファイル
$ cat /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet dhcp
    post-up route add -net 172.31.0.0/16 gw 10.13.0.145  // networkの場合
    post-up route add -host 172.31.0.10/32 gw 10.13.0.145  // hostの場合
```

<br>
### CentOS の場合

```text:ファイル
$ cat /etc/sysconfig/network-scripts/route-eth0 
# Static route for metadata service
172.31.0.0/16 via 10.13.0.145 dev eth0 // networkの場合
172.31.0.10/32 via 10.13.0.145 dev eth0 // hostの場合
```

```text:ファイル
$ sudo /etc/init.d/network restart
```

もし`route-eth0`の`0`の部分は設定したい_eth_によって変えてください。


<br>
## 確認
ということで追加した後の設定は以下の状態になります。

```bash:コマンド
$ netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.13.0.1       0.0.0.0         UG        0 0          0 eth0
10.13.0.0       0.0.0.0         255.255.248.0   U         0 0          0 eth0
172.31.0.0      10.13.0.145     255.255.0.0     UG        0 0          0 eth0
172.31.0.10     10.13.0.145     255.255.255.255 UGH       0 0          0 eth0
```

<br>
# ルーティングの削除
ルーティングの削除にも一時的または永続的の２通りあります。コマンドでの削除は一時的なものですが。永続的に削除をしたい場合は設定ファイルの記載から削除してあげる必要があります。

<br>
## 一時的な削除

一時的な削除は追加の時と同じでコマンドで行います。ここでも`route`コマンドと`ip`コマンドの２通りを紹介します。


<br>
### routeコマンド

#### ・networkの削除

```bash:コマンド
$ sudo route add -net 172.31.0.0 gw 10.13.0.145 netmask 255.255.0.0 eth0
```

#### ・hostの削除

```bash:コマンド
$ sudo route add -host 172.31.0.10 gw 10.13.0.145 eth0
```

追加の時と同じで、_network_と_host_の違いは`-net`が`-host`になるのと、`netmask`が不要になるところです。`eth0`の箇所も無くても大丈夫です。

<br>
### ipコマンド

#### ・networkの削除

```bash:コマンド
$ sudo ip route del 172.31.0.0/16
```

#### ・hostの削除

```bash:コマンド
$ sudo ip route del 172.31.0.10/32
```

こちらも追加と同じで_host_の場合は_netmask_を`/32`にするだけです。


<br>
## 永続的な削除

ただ、追加した箇所を削除するだけですので割愛します。



<br>
## 確認

永続的な設定の場合も`netstat`で確認するとコマンドで追加した場合と同様の状態と取ります。

```bash:コマンド
$ netstat -nr
Kernel IP routing table
Destination     Gateway         Genmask         Flags   MSS Window  irtt Iface
0.0.0.0         10.13.0.1       0.0.0.0         UG        0 0          0 eth0
10.13.0.0       0.0.0.0         255.255.248.0   U         0 0          0 eth0
172.31.0.0      10.13.0.145     255.255.0.0     UG        0 0          0 eth0
172.31.0.10     10.13.0.145     255.255.255.255 UGH       0 0          0 eth0
```

<br>
# おわりに
今までのルーティングの設定は各サーバーに設定しなければならないので、台数が多くなればなるほど大変でした。
そういった煩雑さを軽くしてくれたAWSのルートテーブルは本当に便利だなと思います。

