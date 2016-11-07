---
title: S3で構築したサイトにCloudFrontとCertificate Managerを使ってSSLを導入する。
date: 2016-11-07
tags: AWS, S3, CloudFront, Certificate Manager
author: kohei
ogp:
  og: '現在、S3をベースに構築したサイト(blog.proudit.jp)をCloudFrontを使ってHTTPSへ切り替え>ることにしました。
また、HTTPへのアクセスは全てHTTPSへリダイレクトするようにCloudFront側で設定もします'
---

# はじめに
現在、S3をベースに構築したサイト(blog.proudit.jp)をCloudFrontを使ってHTTPSへ切り替えることにしました。
また、HTTPへのアクセスは全てHTTPSへリダイレクトするようにCloudFront側で設定もします。
![http→https_after.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c9195bfc-8790-b00a-6970-7428fd18078a.png)


>**流れ**
1.証明書の作成(Certificate Manager)
2.SSLの設定(CloudFrontの導入)
3.DNS切り替え(Route53)


<br>
# 1. 証明書の作成(Certificate Manager)
まずは**Certificate Manager**で証明書の作成です。
「AWS > Certificated Manager」をクリック。

・**リージョン**を**バージニア**に変更します。
証明書はバージニアで作成しないと**CloudFront**へ導入できないので注意してください。
![01_CertificatedManager01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9bcfce0b-2e00-7290-c78f-0928744b16cf.png)

・「**今すぐ始める**」または「**証明書のリクエスト**」をクリックします。
![01_CertificatedManager02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/cfb938f4-3e38-a37b-cba5-88c75da47e79.png)

<br>
## ステップ1:ドメイン名の追加
・ドメイン名に取得するドメイン名を入力し「**確認とリクエスト**」をクリックします。
![01_CertificatedManager03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7cec386e-a929-c3e4-4b7e-303e8b3d1076.png)

<br>
## ステップ2:確定とリクエスト
・内容に問題なければ「**確定とリクエスト**」をクリックします。
![01_CertificatedManager04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f72fd1f1-2a0c-60df-b4ea-a78792697fec.png)

<br>
## ステップ3:検証
・「**続行**」をクリック。すると検証Eメールがドメイン情報を元に送られます。
ドメイン部分を開くと送信先が表示されます。
![01_CertificatedManager05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/60851214-e514-9974-f9a6-3fe3f08e0c48.png)

検証が認証されるまで「**検証保留中**」になります。検証が完了すると「**発行済**」となります。
![01_CertificatedManager06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4ec0abbf-818a-4311-d2ac-24e5832565c7.png)

![01_CertificatedManager07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ac7c9345-0e27-4e74-df8a-1d5608f1bf08.png)


<br>
# 2. SSL設置(CloudFront)
「AWS > CloudFront」をクリック。

<br>
## Distributions
・「**Create Distribution**」をクリックします。
![02_CloudFront01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f7c1f886-2020-8d95-d1f6-61e194f1fd2c.png)

<br>
## Step 1:Select delivery method
・Webの「**Get Started**」をクリックします。
![02_CloudFront02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3d2222de-a3a1-255e-198d-9f4352acebd3.png)

<br>
## Step 2:Create distribution
### Origin Settings
・**Origin Domain Name**に設定したいS3バケット名を選択します。
・**Restrict Bucket Access**という項目が現れるので「**Yes**」をチェックします。
・**Create Read Permissions on Bucket**を「**Yes, Update Bucket Policy」**にチェックします。
![02_CloudFront03-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2ff4fca3-ff3e-5bf4-6437-0e05f56a6b41.png)

### Default Cache Behavior Settings
・**Viewer Protocol Policy**で「**Redirect HTTP to HTTPS**」を選択します。
![02_CloudFront03-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/32f7b7e2-ac44-13bd-c684-e8e76e13f672.png)

### Distribution Settings
・**Alternate Domain Names**に**ドメイン名**を入力します。
・**SSL Certificate**を「**Custom SSL Certificate**」を選択し、先ほど**Certificate Manager**で作成した証明書を選択します。
![02_CloudFront03-3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6521ed3b-57f4-bdc0-da3c-ccb6a37a1262.png)

・**Default Root Object**に「**index.html**」を入力します。
![02_CloudFront03-4.png](https://qiita-image-store.s3.amazonaws.com/0/82090/15661966-87ea-38d5-da58-e4042d3c5450.png)

・「**Create Distribution**」をクリックして作成します。
![02_CloudFront03-5.png](https://qiita-image-store.s3.amazonaws.com/0/82090/eb4cf2e6-3f99-30ae-03a7-734f54669f5b.png)

![02_CloudFront04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f620f0d4-35e7-ac95-c3b8-a9e85afb9cb2.png)

・「**In Progress**」が「**Deployed**」になったら完了です。
![02_CloudFront05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/acee079f-cf68-79bc-ded1-aead2df2cb93.png)


<br>
# DNS設定変更(Route53)
「AWS > Route53」をクリック。

・「Hosted zones > 対象のDomain Name」をクリックします。
![03_Route5301.png](https://qiita-image-store.s3.amazonaws.com/0/82090/24815215-e12a-cf10-b43c-33030fc23143.png)

・対象のレコードをクリックし**Alias Target**で先ほど作成した**CloudFront**を指定します。
![03_Route5302.png](https://qiita-image-store.s3.amazonaws.com/0/82090/dc15f877-7d7f-1725-97b3-df0ddfbc21db.png)

・「**Save Record Set**」をクリックして保存します。
![03_Route5303.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4fdaddad-0422-8d9f-a10a-6fe91c6b88c1.png)

・サイトにアクセスするとhttpsでアクセスされているのがわかります。
![04_Browser01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/045ff014-e6ae-5457-4ad3-a9c1294fb213.png)

以上でSSLの導入が完了です。


<br>
# ポイント
設定する際に注意するポイントは3つです。
ひとつ目めは、
**「Certificate Managerでバージニアを選択すること。」**
現時点でCloudFrontへ導入するにはバージニアでSSLを作成しなければなりません。もし他のリージョンで作成した場合、CloudFrontの「**Custom SSL Certificate**」に作成した証明書が表示されなくてハマりポイントになります。

ふたつ目は、
**「CloudFrontからS3へのアクセス権限を付与すること。」**
CloudFront作成時に**Create Read Permissions on Bucket**の項目を
「**Yes, Update Bucket Policy**」にチェックを入れることで、S3の**Origin Access Identity**を同時に作成し、S3のアクセスポリシーを修正してくれます。

そして最後のみっつ目は、
**「CloudFrontを作成する際のDefault Root Objectにindex.htmlを入力すること。」**
ここを入力しておかないとルートでアクセスした際にコンテンツが見つからなくなってしまいます。


<br>
# おわりに
「S3 + CloudFront + Certificate Manager」の3つを組み合わせることでセキュアなサイトが簡単に作れます。
また、サーバーレスなので運用面でも費用面でもコストが限りなく抑えることができるのでシンプルなサービスサイトや告知だけのキャンペーンサイトにとてもオススメです。

サイトの**SSL導入ご検討**や**サーバレス化へのご興味**がお有りの方はぜひ**[「お問い合わせ」](https://proudcloud.jp/contact/)**よりご相談ください。
