---
title: bindtoroute53.plとdnscurl.plを使ってRoute53にBINDのゾーン情報を登録する。
date: 2016-10-13
tags: AWS,Route53
author: kohei
ogp:
  og: 'DNSを他から**Route53**へ移行するときどうしてますか？
ゾーン情報があればGUIから「Import Zone File」でコピペして完了ですが、いちいち管理コンソールへログインしてHosted Zoneを作成して。。。ttl部分を避けてコピペしないと行けなかったり、複数ドメインあったら一つ一つファイル開いてコピペしないとだ>し。。。って正直面倒で仕方ないです。。。'
---

# はじめに
DNSを他から**Route53**へ移行するときどうしてますか？
ゾーン情報があればGUIから「**Import Zone File**」でコピペして完了ですが、いちいち管理コンソールへログインして**Hosted Zone**を作成して。。。ttl部分を避けてコピペしないと行けなかったり、複数ドメインあったら一つ一つファイル開いてコピペしないとだし。。。って正直面倒で仕方ないです。。。
そんな時に[**bindtoroute53.pl**](https://aws.amazon.com/developertools/Amazon-Route-53/4495891528591897)と[**dnscurl.pl**](https://aws.amazon.com/developertools/Amazon-Route-53/9706686376855511)を利用すると、BINDのゾーン情報をGUIから行わなくても設定が可能になるのでとても便利で時短になります。


<br>
# ツールのダウンロード
まずはじめに、[**bindtoroute53.pl**](https://aws.amazon.com/developertools/Amazon-Route-53/4495891528591897)をダウンロードします。
![bindtoroute53.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0e98bbeb-0537-4c7c-8e16-32601fc56f0e.png)

次に[**dnscurl.pl**](https://aws.amazon.com/developertools/Amazon-Route-53/9706686376855511)をダウンロードします。
![dnscurl.png](https://qiita-image-store.s3.amazonaws.com/0/82090/565117de-80f4-193f-9947-07811c9f33b0.png)


<br>
# BIND → Route53
**bindtoroute53.pl**でBINDから取得したゾーン情報を**Route53**へ登録するためのXMLファイルに変換します。

```bash:変換
$ $ ./bindtoroute53.pl --ignore-origin-ns --ignore-soa --origin hogehoge.jp < hogehoge.jp.zone > hogehoge.jp.xml

Ignoring 'hogehoge.jp.	300	IN	SOA	ns1.nameserver.jp. postmaster.nameserver.jp.hogehoge.jp. (
					1355980110	;serial
					10800     	;refresh
					3600      	;retry
					604800    	;expire
					300    )	;minimum', --ignore-soa enabled.
Ignoring 'hogehoge.jp.	300	IN	NS	ns1.nameserver.jp.', --ignore-origin-ns enabled.
Ignoring 'hogehoge.jp.	300	IN	NS	ns2.nameserver.jp.', --ignore-origin-ns enabled.
```

<br>
# Hosted  Zoneの作成
登録するための**Hosted Zone**を作成します。

```bash:HostedZone作成
$  aws route53 create-hosted-zone --name hogehoge.jp --caller-reference `date +%Y-%m-%d_%H-%M-%S`

{
    "HostedZone": {
        "ResourceRecordSetCount": 2, 
        "CallerReference": "2016-10-12_23-42-18", 
        "Config": {
            "PrivateZone": false
        }, 
        "Id": "/hostedzone/Z2B42SHHTH6TX1", 
        "Name": "hogehoge.jp."
    }, 
    "DelegationSet": {
        "NameServers": [
            "ns-498.awsdns-62.com", 
            "ns-844.awsdns-41.net", 
            "ns-1215.awsdns-23.org", 
            "ns-1972.awsdns-54.co.uk"
        ]
    }, 
    "Location": "https://route53.amazonaws.com/2013-04-01/hostedzone/Z2B42SHHTH6TX1", 
    "ChangeInfo": {
        "Status": "PENDING", 
        "SubmittedAt": "2016-10-12T14:42:20.702Z", 
        "Id": "/change/C1N36QDVJM9J4O"
    }
}
```


<br>
# Route53へ登録

まず、「*.aws-secrets*」を作成します。

```bash:設定ファイル作成
$ vi .aws-secrets 
```

内容は以下です。

```bash:.aws-secrets
%awsSecretAccessKeys = (
    "my-aws-account" => {
        id => "********************",
        key => "****************************************",
    },
);
```

作成したら**dnscurl.pl**コマンドで**Route53**へ情報を登録します。

```bash:登録
$ ./dnscurl.pl --keyname my-aws-account -- -H "Content-Type: text/xml; charset=UTF-8" -X POST --upload-file hogehoge.jp.xml https://route53.amazonaws.com/2010-10-01/hostedzone/Z2B42SHHTH6TX1/rrset | tee out

  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  3127  100   276  100  2851    247   2552  0:00:01  0:00:01 --:--:--  2554
<?xml version="1.0"?>
<ChangeResourceRecordSetsResponse xmlns="https://route53.amazonaws.com/doc/2010-10-01/"><ChangeInfo><Id>/change/C2ZJGJOSDSK9L0</Id><Status>PENDING</Status><SubmittedAt>2016-10-12T16:19:08.986Z</SubmittedAt></ChangeInfo></ChangeResourceRecordSetsResponse>
```

以上で完了です。


<br>
# おわりに
はじめにも述べましたが、ゾーン情報はGUIからコピペで登録可能ですが、やはりいちいちファイル開いてコピペはちょっと面倒かなと。。。時間もかかりますし。
なので、環境の下準備(.aws-secretsの作成とか)が出来てしまえばこっちの方がミスするポイントも減って、時間の短縮もできてとても楽になるのではないでしょうか？

