---
title: 第３回 AWSとIDCFをVPN接続する - VPN接続編（全４回）
date: 2016-05-16
tags: IDCFクラウド, AWS, VPN
author: kohei
---

# はじめに
---
[<< 前回：第２回 AWSとIDCFをVPN接続する - AWS準備編（全４回）](http://qiita.com/kooohei/items/fbc6b32f5a70bf3cfa20)
IDCFクラウドにVyOSで仮想マシンを作成して、IDCFクラウドとAWSをVPNで接続する設定を説明します。
![idcf-vpn-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9b15d672-f654-ab05-fb61-57cf8951b58e.png)

ここまでで、IDCFとAWSの両方にVPNゲートウェイのを用意するところまで完了しました。
前回の「VPN接続の作成」の際に「設定のダウンロード」を行っているのであとはそのAWS側で取得したコンフィグをIDCF側で設定してあげれば接続できるようになります。
ということで今回はIDCFとAWS間の接続設定を行います。
![idcf-vpn-4.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2111d578-734d-ad00-1175-1c6bce14db14.png)


<br>
## VPN接続設定 - IDCF
---
・VyOSへログイン

```bash:コマンド
$ ssh vyos@<サーバーIP> -i <鍵のパス>
```

<br>
・コンフィグの流し込み
前回の[第２回 AWSとIDCFをVPN接続する（全４回）]()で「VPN接続の作成」の「設定をダウンロード」した際にダウンロードしたコンフィグを流し込みます。(コピペでOK)
もしうまくいかない場合はコメントアウト（先頭に「!」がある行)を除いてみてください。

<br>
・VPC Tunnelのlocal-address設定

```bash:コマンド
vyos@vyos# set vpn ipsec site-to-site peer 52.192.68.69 local-address 10.13.0.146
[edit]
vyos@vyos# set vpn ipsec site-to-site peer 52.193.106.189 local-address 10.13.0.146
[edit]
```

<br>
・設定の保存
設定を保存します。

```bash:コマンド
vyos@vyos# commit
[edit]
vyos@vyos# save
Saving configuration to '/config/config.boot'...
Done
[edit]
```

<br>
・IPsec再起動
基本的には設定を保存した時点で接続されますが、一応再起動しておきます。

```bash:コマンド
$ sudo /etc/init.d/ipsec restart
Restarting strongswan IPsec services: ipsecStopping strongSwan IPsec...
Starting strongSwan 4.5.2 IPsec [starter]...
.
```

<br>
・接続確認
vti0とvti1がAWSと接続しているtunnelです。どちらもu/u(Up)しているのが確認できます。

```bash:コマンド
$ show interfaces
Codes: S - State, L - Link, u - Up, D - Down, A - Admin Down
Interface        IP Address                        S/L  Description
---------        ----------                        ---  -----------
eth0             10.13.0.146/21                    u/u
lo               127.0.0.1/8                       u/u
                 ::1/128
vti0             169.254.25.22/30                  u/u  VPC tunnel 1
vti1             169.254.24.82/30                  u/u  VPC tunnel 2
```
ここでもvti0とvti1がconnectedと成っているが確認できます。

```bash:コマンド
$ show ip route
Codes: K - kernel route, C - connected, S - static, R - RIP, O - OSPF,
       I - ISIS, B - BGP, > - selected route, * - FIB route

S>* 0.0.0.0/0 [210/0] via 10.13.0.1, eth0
C>* 10.13.0.0/21 is directly connected, eth0
C>* 127.0.0.0/8 is directly connected, lo
C>* 169.254.24.80/30 is directly connected, vti1
C>* 169.254.25.20/30 is directly connected, vti0
```
「VPC tunnel 1と2」2つのvti接続が確認でき、どちらもStateがupと成っています。

```bash:コマンド
$ show vpn ipsec sa
Peer ID / IP                            Local ID / IP
------------                            -------------
52.192.68.69                            10.13.0.146

    Description: VPC tunnel 1

    Tunnel  State  Bytes Out/In   Encrypt  Hash    NAT-T  A-Time  L-Time  Proto
    ------  -----  -------------  -------  ----    -----  ------  ------  -----
    vti     up     7.4K/6.6K      aes128   sha1    yes    1587    3600    all

Peer ID / IP                            Local ID / IP
------------                            -------------
52.193.106.189                          10.13.0.146

    Description: VPC tunnel 2

    Tunnel  State  Bytes Out/In   Encrypt  Hash    NAT-T  A-Time  L-Time  Proto
    ------  -----  -------------  -------  ----    -----  ------  ------  -----
    vti     up     7.5K/4.9K      aes128   sha1    yes    1262    3600    all
```

また、AWS側は以下で確認できます。


<br>
# おわりに
---
以上で無事IDCF-AWS間をVPN接続できました。
ただ、これだけではただ繫っただけでサーバー間で通信を行うには不完全です。
ということで、次回は最後の仕上げとして通信を行うための設定を行います。

[>> 最終回：第４回 AWSとIDCFをVPN接続する - 最後の仕上げ編（全４回）](http://qiita.com/kooohei/items/6ba28436485096100161)

