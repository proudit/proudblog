---
title: 第２回 AWSとIDCFをVPN接続する - AWS準備編（全４回）
date: 2016-05-09
tags: IDCFクラウド, AWS, VPN
author: kohei
---

# はじめに
---
[<< 前回：第１回 AWSとIDCFをVPN接続する - IDCF準備編（全４回）](http://qiita.com/kooohei/items/906a6ce1352285e793d5)
IDCFクラウドにVyOSで仮想マシンを作成して、IDCFクラウドとAWSをVPNで接続する設定を説明します。
![idcf-vpn-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9b15d672-f654-ab05-fb61-57cf8951b58e.png)
前回はIDCF側にVyOSを利用してVPNゲートウェイを作成しました。
![idcf-vpn-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/903a6791-fb65-6fd3-5ecd-566c1a605c52.png)

今回はAWS側のVPNゲートウェイの作成を行います。
![idcf-vpn-3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a8160ab4-f708-851a-40a1-a2239a67e2f5.png)


<br>
## ゲートウェイの作成 - AWS
---
・AWSマネージメントコンソールにログインします。
https://signin.aws.amazon.com/

<br>
・「サービス > すべてのAWSサービス > VPC」をクリックします。
![idcf-vpn_2_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3c1e1978-9981-2dc9-4bc2-9a80f2f581f1.png)

<br>
・「仮想プライベートゲートウェイ > 仮想プライベートゲートウェイの作成」をクリックします。
![idcf-vpn_2_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/84c49d16-2f80-28a5-c581-7c1034ab22c4.png)

<br>
・「ネームタグ」を入力し「作成」をクリックします。

```text:仮想プライベートゲートウェイ
ネームタグ：VGW-ToIDCF
```
![idcf-vpn_2_03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7865dcbf-7799-2053-cfbf-5cbd6bd402d9.png)
![idcf-vpn_2_04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0dcf384c-7121-e8e7-388a-47c72f1f4236.png)

<br>
・「カスタマーゲートウェイ > カスタマーゲートウェイの作成」をクリックします。
![idcf-vpn_2_05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bbe6ee08-bd67-7e9f-aea2-4ae2c2e9596c.png)

<br>
・各項目を入力し「作成」をクリックします。

```text:カスタマーゲートウェイ
ネームタグ：VPNRouterToIDCF
ルーティング：静的(ここでは動的どちらでもOK)
IPアドレス：xxx.xxx.xxx.xxx（VPN-IDCFのIPを入力）※
BGP ASN：65000(動的の場合は指定)
※第１回 AWSとIDCFをVPN接続する（全４回）の「IPアドレスの設定」で取得したIPです。
```
![idcf-vpn_2_06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/60665788-eb03-624a-7740-c617535df9d7.png)
![idcf-vpn_2_07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0a040c13-9c94-4ee7-da69-e2442031abc9.png)

<br>
・VPN接続の作成：「VPN接続 > VPN接続の作成」をクリックします。
![idcf-vpn_2_08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/18e8f26e-49e1-4c9d-36fc-ffcf48f1f57d.png)

<br>
・各項目を入力し「作成」をクリックします。

```text:VPN接続
ネームタグ：VPNConnectToIDCF
仮想プライベートゲートウェイ：さっき作成した仮想プライベートゲートウェイ
カスタマーゲートウェイ：既存(さっき作成したカスタマーゲートウェイ)
ルーティングオプション：動的(BGPが必要)
```
![idcf-vpn_2_09.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c85f1397-8f10-d704-4192-e9c0257d9121.png)

<br>
・設定のダウンロード
作成したVPN接続を選択し「設定のダウンロード」をクリックします。
![idcf-vpn_2_10.png](https://qiita-image-store.s3.amazonaws.com/0/82090/45699772-b199-d6ef-0210-e3aecfde52d9.png)

<br>
・Vyattaを選択し「ダウンロード」をクリックしてConfigをダウンロードします。

```text:設定
ベンダー：Vyatta
プラットフォーム：Vyatta Network OS
ソフトウェア：Vyatta Network OS 6.5+
```
![idcf-vpn_2_12.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d1da47b7-051b-d5a4-de57-79f72ac46887.png)


<br>
## VPCへのアタッチ
---
・対象となる「仮想プライベートゲートウェイ」を選択して「VPCにアタッチ」します。
![idcf-vpn_3_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b5a6bb85-ec13-83bb-ba6a-0f0decd0af5d.png)

<br>
・アタッチしたい「VPC」を選んで「アタッチ」をクリックします。
![idcf-vpn_3_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f5d48024-7396-4036-9c8b-50bf6bddbf69.png)


<br>
# おわりに
---
これでAWS側のVPNゲートウェイの作成が完了しました。あとは両方で作成したVPNゲートウェイを繋げる設定をしてあげるだけです。

ということで次回はIDCF側で作成したVPNゲートウェイに繋げるための設定を行います。

[>> 次回：第３回 AWSとIDCFをVPN接続する - VPN接続編（全４回）](http://qiita.com/kooohei/items/f16dcb9e7280b29deee7)

