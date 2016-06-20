---
title: IDCFクラウド】cloudstack-apiで仮想マシンにパブリックIPを付与する。
date: 2016-06-20
tags: IDCFクラウド
author: kohei
---

# はじめに
---
前回、[【IDCFクラウド】cloudstack-apiで仮想マシンを作成する。](http://qiita.com/kooohei/items/7690b526edf453fc15d6)では_cloudstack-api_コマンドで仮想マシンを作成しました。
今回はその続編として、作成した仮想マシンにパブリックIPを付与したいと思います。


<br>
## 事前確認
まずは現在のパブリックIPを確認します。

```bash:コマンド
$ cloudstack-api listPublicIpAddresses -t ipaddress
```

```text:戻り値
+-----------------+
|    ipaddress    |
+-----------------+
| ***.***.***.*** |
+-----------------+
```


<br>
## パブリックIPの取得
パブリックIPの取得は`associateIpAddress `コマンドで行います。

```bash:コマンド
$ cloudstack-api associateIpAddress \
 --zoneid a53ff3d3-042b-4cbd-ad16-494bb8d33e06
```

```text:戻り値
{
  "associateipaddressresponse": {
    "id": "061c31aa-aa41-4e03-a274-83b17b58c1a3",
    "jobid": "b32b867c-07d4-412e-b514-94a1eee62ed1"
  }
}
```

|オプション |内容   |
|--------|-------|
|--zoneid|ゾーンID|

簡単に説明すると、

「_radian_ゾーンにパブリックIPを割り当てる（取得する）」

という内容になります。


<br>
## 確認
先ほどの`listPublicIpAddresses`コマンドで確認してみましょう。

```bash:コマンド
$ cloudstack-api listPublicIpAddresses -t ipaddress,id,virtualmachinename
```

```text:戻り値
+----------------+--------------------------------------+--------------------+
|   ipaddress    |                  id                  | virtualmachinename |
+----------------+--------------------------------------+--------------------+
| 210.129.19.191 | 061c31aa-aa41-4e03-a274-83b17b58c1a3 | None               |
| ***.***.***.***| ********-****-****-****-************ | None               |
+----------------+--------------------------------------+--------------------+
```

`210.129.19.191` のIPが割り当てられているのが確認できました。


<br>
# NAT設定
---
取得が確認できたら次はNATの設定です。
パブリックIPを仮想マシンへ割り当てます。

```bash:コマンド
$ cloudstack-api enableStaticNat \
--ipaddressid 061c31aa-aa41-4e03-a274-83b17b58c1a3 \
--virtualmachineid b1230e50-f75b-4343-8d6e-ca7a4efcf2b0
```

```text:戻り値
{
  "enablestaticnatresponse": {
    "success": "true"
  }
}
```

|オプション           |内容               |
|------------------|------------------|
|--ipaddressid     |パブリックIPアドレスID  |
|--virtualmachineid|仮想マシンID        |

戻り値で`"success": "true"`となっていれば完了です。


<br>
## 確認
先ほど実行した戻り値でも確認はできていますが、一応`listPublicIpAddresses`コマンドでも確認しましょう。

```bash:コマンド
$ cloudstack-api listPublicIpAddresses -t ipaddress,id,virtualmachinename,virtualmachinedisplayname
```

```text:戻り値
+----------------+--------------------------------------+--------------------+----------+---------------------------+
|   ipaddress    |                  id                  | virtualmachinename | hostname | virtualmachinedisplayname |
+----------------+--------------------------------------+--------------------+----------+---------------------------+
| 210.129.19.191 | 061c31aa-aa41-4e03-a274-83b17b58c1a3 | test-host          | None     | create-test               |
| ***.***.***.***| ********-****-****-****-************ | None               | None     | None                      |
+----------------+--------------------------------------+--------------------+----------+---------------------------+
```

ということで、先ほど取得したパブリックIPアドレスが割り当てられているのを確認できました。
ここで出力している項目ですが_virtualmachinename_はサーバ自身の_hostname_となります。コンソールで表示される「仮想マシン名」は_virtualmachinedisplayname_です。


<br>
# おわりに
---
仮想マシンにパブリックIPが付与されたのでこれで外部との通信経路が用意されました。
ですが実はまだ通信はできません。。。FWで許可されていないからです。
ということで、次回はFWの設定をcloudstack-apiで行いたいと思います。

