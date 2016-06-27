---
title: 【IDCFクラウド】cloudstack-apiで仮想マシンを作成する。
date: 2016-06-14
tags: IDCFクラウド
author: kohei
---

# はじめに
---

cloudstack-apiで仮想マシンの構築を行いたいと思います。


<br>
## 基本情報

ということで、今回は以下の情報をもとに仮想マシンのを作成を行います。

|項目　　　　　　　   |名前                           |
|----------|------------------------------|
|ゾーン　　　　　　　　　 |radian                        |
|インスタンス |light.S1                      |
|テンプレート |Ubuntu Server 14.04 LTS 64-bit|
|IP        |10.13.0.50                    |
|所属グループ|test                          |
|ホスト名    |test-name                     |
|ディスプレイ名|create-test                   |
|キーペア    |hogehoge                      |


<br>
# 事前確認
---
仮想マシンを作成する前にまず、現在IDCFクラウドでの稼働状況を確認しておきたいと思います。

```bash:コマンド
$ cloudstack-api listVirtualMachines -t name
```

```text:戻り値
no data found
```

現在、環境内には１台も仮想マシンが作成されていないため_no data found_となっています。

<br>
# 仮想マシンの作成
---
それでは仮想マシンを作成しましょう。

作成には`createInstanceGroup`を利用します。

```bash:コマンド
$ cloudstack-api deployVirtualMachine \
--zoneid a53ff3d3-042b-4cbd-ad16-494bb8d33e06 \
--serviceofferingid e01a9f32-55c4-4c0d-9b7c-d49a3ccfd3f6 \
--templateid 6eee3f7d-2193-4df7-81d5-bc2169ac3380 \
--ipaddress 10.13.0.50 \
--name test-host \
--keypair hogehoge \
--displayname create-test \
--group test
```

```text:戻り値
{
  "deployvirtualmachineresponse": {
    "id": "b1230e50-f75b-4343-8d6e-ca7a4efcf2b0",
    "jobid": "dee8c58d-069a-408a-98c3-03ea1e4e3c50"
  }
}
```
今回指定したオプションについての説明は以下のとおりです。

|オプション            |内容                        |
|-------------------|---------------------------|
|--zoneid           |ゾーン環境ID                 |
|--serviceofferingid|インスタンスID                |
|--templateid       |テンプレートのID               |
|--ipaddress        |IPアドレス                    |
|--name             |ホスト名                     |
|--keypair          |デフォルト(root)で利用するキーペア|
|--displayname      |コンソール画面で表示される名前    |
|--group            |仮想マシンが所属するグループ     |

簡単に説明すると、

・_ipaddress_オプションで仮想マシンに`10.13.0.50`のIPアドレスを付与
・SSHログインするために必要なデフォルトキーは`hogehoge`を配置
・_name_オプションでSSHログインした際に表示されるホスト名を`test-host`に設定

といった内容になります。

また、仮想マシンに直接影響はありませんが、

・_group_オプションで仮想マシンを`test`にグルーピング
・_diplayname_オプションでコンソール画面での表示を`create-test`に設定

を行っています。


<br>
# 確認
---
確認はコンソールおよびコマンドでも可能です。

###コンソール画面で確認
![cloudstack-api_createvm01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/39962077-6be0-39ff-bba7-87d00e4823b7.png)

<br>

###コマンドで確認

```bash:コマンド
$ cloudstack-api listVirtualMachines -t name,keypair,displayname,group
```

```text:戻り値
+-----------+----------+-------------+-------+
|    name   | keypair  | displayname | group |
+-----------+----------+-------------+-------+
| test-host | hogehoge | create-test | test  |
+-----------+----------+-------------+-------+
```


<br>
# おわりに
---
今回、仮想マシンを作成しましたが、このままではグローバルIPが無いため外部との通信ができません。
次回は仮想マシンをグローバルIPに付与するところをcloudstack-apiコマンドで行いたいと思います。
[>>【IDCFクラウド】cloudstack-apiで仮想マシンにパブリックIPを付与する。](http://blog.proudit.jp/2016/06/20/associate-a-publicip-to-the-virtualmachine-by-cloudstack-api.html)

