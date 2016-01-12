---
title: 「AWS WAF」を導入してみた。- IP addresses編
date: 2015-12-28
tags: AWS, WAF, CloudFront
author: kohei
---

WS WAFはアプリケーション用のファイアウォールで、
IP address、SQL injection、String matchingに関するアクセスの制御ができます。

ただ、このサービスを利用するにはCloudFront経由でのアクセスにしか対応していないため、ELBやEC2にWAFを導入する場合はCloudFrontを配置する必要があります。

今回はIP addressesの設定を行います。
その他の設定については以下を参照ください。
[「AWS WAF」を導入してみた。- SQL injection編](../../../2016/01/07/aws-waf-sqlinjection.html)
[「AWS WAF」を導入してみた。- String matching編](../../../2016/01/12/aws-waf-stringmatching.html)

# 1.新規設定
---
今回は新規で特定IPアドレスからのアクセスをブロックする設定をします。
まずはじめに画面中央にある「Get started」をクリックします。
![aws-waf_2015120101.png](https://qiita-image-store.s3.amazonaws.com/0/82090/efb26a7f-2d80-b239-4084-90c86b13aa3a.png)


Concepts overview画面が表示されますが右下の「Next」をクリックします。
![aws-waf_2015120102.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c511e13b-9596-060d-c4d7-347ec52b1708.png)


<br>  
## Step 1: Name web ACL
作成するWeb ACLの名前を入力します。これはWAFで設定する複数のルールをまとめるためのグループ名となるので、導入するサービス名などをつけるのが良いと思います。
今回は「waf-test-acl」にします。
![aws-waf_2015120103-step1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0df8bfbf-ce26-698e-1dca-84a86b45bca3.png)


<br>  
## Step 2: Create conditions
今回はIPアドレスのアクセスコントロール設定をするので「IP match conditions」の「Create IP match condition」をクリックします。
![aws-waf_2015120103-step2-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/13711371-ecf1-204e-0553-0df570b452ba.png)


するとIPアドレスを設定する画面がポップアップされるためIPアドレス名とIPアドレス(レンジ指定可)を入力して「Create」をクリックします。
![aws-waf_2015120103-step2-2-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fc4bafd9-8cea-10f6-c6d4-15861caeb638.png)


作成が完了したら「Next」をクリックします。


<br>  
## Step 3: Create rules
「Create rule」をクリックするとルールを設定する画面がポップアップされます。
![aws-waf_2015120103-step3-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7613d6a2-a2c3-d688-300c-161756d26620.png)

今回の場合は「リクストが該当IP(waf-test-ip)からのアクセスからの場合」というルールを設定しています。
![aws-waf_2015120103-step3-2-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7562a015-1416-658a-7d1a-af63e248c329.png)

設定が完了したら「Create」をクリックします。
作成したらそのルールにマッチした際のアクション(Allow, Block, Count)と、マッチしない場合のデフォルトアクション(Allow, Block)を設定し「Next」をクリックします。
![aws-waf_2015120103-step3-3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/12b1af6d-c5e2-4a34-09ca-fcfb30c31fd6.png)

今回はデフォルトアクションをAllowとし、該当IP(ip-deny-rule)からのリクエストはBlockを設定します。


<br>  
## Step 4: Choose AWS resource
Resourceの項目を適用したいCloudFrontに設定して「Review and create」をクリックします。
![aws-waf_2015120103-step4-1-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/da06dd26-46f8-7fd9-a3e7-72ee273f4862.png)


<br>  
## Step 5: Review and create
最後に今までのStepで設定した内容が表示されるのでOKであることを確認して「Confirm and distribution」をクリックします。
![aws-waf_2015120103-step5-1-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b35d35f3-58ca-47f0-90cd-72af62ada0b1.png)

作成が完了した後「Requests」タブをクリックするとリクエストログが確認できます。
![aws-waf_2015120104-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/cd7286f2-75a5-a5e5-3656-0e1e449f28d9.png)


<br>  
# 2.動作確認
---
まずはリクエストが無いことを確認します。
![aws-waf_2015120105.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ec9359fe-028f-3c74-8f39-64f0b1973f2c.png)

CloudFront経由でサーバへブラウザアクセスすると以下の画面が表示されます。
![aws-waf_2015120106-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f073bee1-f30f-ffea-5b07-39a871f75d4d.png)

再度リクエストログのMatches ruleを確認すると「ip-deny-rule(Block)」というログが出ているのが確認でます。

今回ブロック対象としたIPからのみブロックできているのが確認できました。
![aws-waf_2015120107-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c9a7a629-e448-fb6d-6430-86837b409f72.png)


以上で設定完了です。

