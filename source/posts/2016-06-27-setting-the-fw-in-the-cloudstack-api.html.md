---
title: 【IDCFクラウド】cloudstack-apiでFWの設定をする。
date: 2016-06-27
tags: IDCFクラウド
author: kohei
---

# はじめに
---

前回[【IDCFクラウド】cloudstack-apiで仮想マシンにパブリックIPを付与する。](http://qiita.com/kooohei/items/524c1d5b4e541c695c06)を行いました。
さらにその前の回(前々回)では[【IDCFクラウド】cloudstack-apiで仮想マシンを作成する。](http://blog.proudit.jp/2016/06/14/make-virtual-machine-by-cloudstack-api.html)を行いました。
これよって「仮想マシンを作成し、パブリックIPの付与」まで完了しました。
ただ、これでは外部との通信ができません。IDCFクラウドのFWはホワイトリスト方式のため、必要なポートを指定して開けてあげる必要があります。
ということで、今回は_cloudstack-api_コマンドでFWの設定を行います。


<br>
# 事前確認
---

まずは現在のFW状況を確認します。

```bash:コマンド
$ cloudstack-api listFirewallRules --ipaddressid 8ac2bf54-e238-43b2-89be-4bec101d694e -t ipaddress,startport,endport,protocol,ciderlist,id
```

```text:戻り値
no data found
```

| オプション       | 内容            |
|:-------------:|:--------------:|
| --ipaddressid | パブリックIPアドレス |

指定したパブリックIPに何もFWの設定がないため`no data found`となっています。


<br>
# FWルールの作成
---

FWルールの作成は`createFirewallRule`コマンドで行います。

```bash:コマンド
$ cloudstack-api createFirewallRule --ipaddressid 8ac2bf54-e238-43b2-89be-4bec101d694e --protocol TCP --startport 80 --endport 80
```

```text:戻り値
{
  "createfirewallruleresponse": {
    "id": "f47780b8-0507-4b10-9c8c-0ff08d0456ac",
    "jobid": "61c80d83-6e0b-4302-b004-738dbc40ba59"
  }
}
```

それではもう一度FWの設定を確認してみましょう。

```bash:確認
$ cloudstack-api listFirewallRules --ipaddressid 8ac2bf54-e238-43b2-89be-4bec101d694e -t ipaddress,startport,endport,protocol,ciderlist,id
```

```text:戻り値
+----------------+-----------+---------+----------+-----------+--------------------------------------+
|   ipaddress    | startport | endport | protocol | ciderlist |                  id                  |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
| 210.129.22.172 | 80        | 80      | tcp      | None      | f47780b8-0507-4b10-9c8c-0ff08d0456ac |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
```
80番ポートが解放されたのが確認できました。

FWの解放は範囲を指定して行うことができます。その場合は_--startport_の値に始まりとなるポート番号、_--endport_に終わりとなるポート番号を指定します。

```bash:コマンド
$ cloudstack-api createFirewallRule --ipaddressid 8ac2bf54-e238-43b2-89be-4bec101d694e --protocol TCP --startport 8000 --endport 8100
```

```text:戻り値
{
  "createfirewallruleresponse": {
    "id": "a3d25f8c-ebd0-458c-b86b-49cfcb6592d1",
    "jobid": "aeaa1a60-a754-40bb-8bc0-142fa7eee3a5"
  }
}
```

```bash:コマンド
$ cloudstack-api listFirewallRules --ipaddressid 8ac2bf54-e238-43b2-89be-4bec101d694e -t ipaddress,startport,endport,protocol,ciderlist,id
```

```text:戻り値
+----------------+-----------+---------+----------+-----------+--------------------------------------+
|   ipaddress    | startport | endport | protocol | ciderlist |                  id                  |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
| 210.129.22.172 | 80        | 80      | tcp      | None      | f47780b8-0507-4b10-9c8c-0ff08d0456ac |
| 210.129.22.172 | 8000      | 8100    | tcp      | None      | a3d25f8c-ebd0-458c-b86b-49cfcb6592d1 |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
```

また、特定IPのみを許可する場合は_--cidrlist_を使います。

```bash:コマンド
$ cloudstack-api createFirewallRule --ipaddressid e72d0249-b3e1-4841-9463-2f56ee9964f5 --protocol TCP --startport 22 --endport 22 --***.***.***.***/32
```

```text:戻り値
{
  "createfirewallruleresponse": {
    "id": "2fa54ca1-0ed9-4bd3-a977-a0b1bb5f19cc",
    "jobid": "109e9497-36bc-4250-84ca-bb9a8d89796c"
  }
}
```

```bash:コマンド
$ cloudstack-api listFirewallRules --ipaddressid e72d0249-b3e1-4841-9463-2f56ee9964f5 -t ipaddress,startport,endport,protocol,ciderlist,id
```

```text:戻り値
+----------------+-----------+---------+----------+-----------+--------------------------------------+
|   ipaddress    | startport | endport | protocol | ciderlist |                  id                  |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
| 210.129.22.172 | 22        | 22      | tcp      | None      | 2fa54ca1-0ed9-4bd3-a977-a0b1bb5f19cc |
| 210.129.22.172 | 80        | 80      | tcp      | None      | f47780b8-0507-4b10-9c8c-0ff08d0456ac |
| 210.129.22.172 | 8000      | 8100    | tcp      | None      | a3d25f8c-ebd0-458c-b86b-49cfcb6592d1 |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
```

以下、利用したオプションについてです。

| オプション       | 内容              |
|:-------------:|:----------------:|
| --ipaddressid | パブリックIPアドレスID |
| --protocol    | プロトコル(TCP/UDP) |
| --startport   | スタートポート       |
| --endport     | エンドポート         |
| --cidrlist    | 許可IP及びNW      |


<br>
# FWルールの削除
---

作成したFWルールの削除は`deleteFirewallRule`コマンドで行います。

```bash:コマンド
$ cloudstack-api deleteFirewallRule --id a3d25f8c-ebd0-458c-b86b-49cfcb6592d1
```

```text:
{
  "deletefirewallruleresponse": {
    "jobid": "cf419432-24dc-404c-a4bf-8b478cfdf9ff"
  }
}
```

| オプション | 内容      |
|:-------:|:---------:|
| --id    | FWルールID |


```bash:
$ cloudstack-api listFirewallRules --ipaddressid 8ac2bf54-e238-43b2-89be-4bec101d694e -t ipaddress,startport,endport,protocol,ciderlist,id
```

```bash:
+----------------+-----------+---------+----------+-----------+--------------------------------------+
|   ipaddress    | startport | endport | protocol | ciderlist |                  id                  |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
| 210.129.22.172 | 22        | 22      | tcp      | None      | 2fa54ca1-0ed9-4bd3-a977-a0b1bb5f19cc |
| 210.129.22.172 | 80        | 80      | tcp      | None      | f47780b8-0507-4b10-9c8c-0ff08d0456ac |
+----------------+-----------+---------+----------+-----------+--------------------------------------+
```

削除されました。


<br>
# おわりに
---

　FWルールはあくまでも**パブリックIPアドレス**に対して行う設定です。なのでプライベートIPに対しては行えません。
もしプライベートネットワーク間での設定を行いたい場合は各サーバでiptablesの設定を行う必要があります。
　また、今回設定したFWルールは**「仮想マシンにNAT接続している限り有効」**という点にも注意が必要です。
一旦、IPの割り当てを解除してしまうと、そのパブリックIPに設定したFWルールは全て消えてしまいます。
そのためFW設定を行う際は**「IPは使いまわせても、FWルールは使い回せない」**ということに気をつけておきましょう。

