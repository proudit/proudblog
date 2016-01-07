---
title: 「AWS WAF」を導入してみた。- SQL injection編
date: 2016-01-07
tags: AWS, WAF, CloudFront
author: kohei
---

# はじめに
---
2015年のre:Inventで「AWS WAF」が発表されました。

AWS WAFはアプリケーション用のファイアウォールで、IP address、SQL injection、String matchingに関するアクセスの制御ができます。
ただ、このサービスを利用するにはCloudFront経由でのアクセスにしか対応していないため、ELBやEC2にWAFを導入する場合はCloudFrontを配置する必要があります。

今回は既に作成済みの「waf-test-acl」にSQL injectionの設定を追加してみます。
その他の設定については以下参照ください。
[「AWS WAF」を導入してみた。- IP addresses編](../../../2015/12/28/aws-waf-ipaddress.html)
[「AWS WAF」を導入してみた。- String matching編](http://qiita.com/kooohei/items/18b908a38a98528550e5)


# 1.設定
---
## ① Conditionの作成
まず、SQL injectionをクリックします。
![aws-waf_sql-injection_2015120401.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3c0e488c-ab1e-ed97-73ef-5f8b66a183ef.png)

「Create condition」をクリックします。
![aws-waf_sql-injection_2015120402.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a8744128-6c9f-e323-dc85-8ca16f70d176.png)

「Name」には任意のコンディション名を入力します。
また、Filter settingsの「Part of the request to filter on」でチェックしたいWeb要求、「Transformation」でAWS WAFがリクエストをチェックする前に行う変換方式を指定し、OKであれば「Add another filter」をクリックして条件に追加します。
![aws-waf_sql-injection_2015120403.png](https://qiita-image-store.s3.amazonaws.com/0/82090/31948ec2-c58c-a4d7-0b26-19504d9f84dd.png)

Filters in this SQL injection match conditionへの追加が確認できたら「Create」をクリックして作成します。
![aws-waf_sql-injection_2015120404.png](https://qiita-image-store.s3.amazonaws.com/0/82090/54e80d2d-720f-349a-96a5-04f6a25697ca.png)

<br>
## ② Ruleの作成
conditionを作成したら、次に「Rules」をクリックします。
![aws-waf_sql-injection_2015120405.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e91e32cb-55dd-1018-0b0a-838d546e070c.png)

Rules設定画面が表示されたら「Create rule」をクリックしルールの作成を行います。
![aws-waf_sql-injection_2015120406.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2c386f4c-78bb-07ae-377c-dd1112e035f6.png)

先ほどConditionsのSQL injectionで作成したルールを設定し、完了したら「Create」をクリックします。
![aws-waf_sql-injection_2015120407.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4e5abd0b-ec03-3f5b-8b8c-72fc924cb72e.png)

ルールの作成が完了したら「Web ACLs」をクリックします。
![aws-waf_sql-injection_2015120408.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f8f07011-cc24-5d48-9b06-b47db0383cee.png)

<br>
## ③ Access Control Listへの追加
今回ルールを追加する対象のACL名をクリックします。
![aws-waf_sql-injection_2015120409.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8340e1bf-1517-1eac-f827-0d4435bbedb5.png)

タブ「Rules」をクリックして「Edit web ACL」をクリックします。
![aws-waf_sql-injection_2015120410-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a4139ba3-e738-78b4-3ac2-3fca43ebe0a1.png)

「Rules」のプルダウンで今回作成したルールを選択し、「Add rule to web ACL」をクリックすると下の”If a request matches all the conditions in a rule, take the corresponding action”に追加されます。そうしたら今回はブロックをしたいため「Block」にチェックし、「Update」をクリックします。
![aws-waf_sql-injection_2015120411.png](https://qiita-image-store.s3.amazonaws.com/0/82090/32de316d-d008-4001-a91c-527d05e48b79.png)

ルールが追加されました。「Requests」タブをクリックするとリクエストログが確認できます。
![aws-waf_sql-injection_2015120412-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/14c360d3-19cc-0783-51aa-c583b61cc2f6.png)


<br>  
# 2.動作確認
---
## ① 現状確認
まずは現状を確認します。リクエストがない状態です。
![aws-waf_sql-injection_2015120414.png](https://qiita-image-store.s3.amazonaws.com/0/82090/4fa2ba96-395b-c49d-6a48-694f3e98cbcc.png)

<br>
## ② ツールの実行
次にsqlmapを実行します。
![aws-waf_sql-injection_2015120419-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2edf7173-9eef-ea55-316f-d33268c8ff1e.png)

<br>
## ③ リクエスト確認
それでは再度、リクエストを確認してみます。
![aws-waf_sql-injection_2015120415-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3e5b73ce-86ff-f935-760e-1f1a4f8f48ed.png)

先ほど設定したルール"sql-injection-rule"によってリクエストが「Block」されているのが確認できます。
さらに今回はUser-Agentに対して設定したので、Request headersのUser-Agentを確認するとどういったリクエストを防いだかがわかります。
![aws-waf_sql-injection_2015120416-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9c7297be-2382-0036-f87a-96050f749dfe.png)

![aws-waf_sql-injection_2015120417-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/68bfd374-a6d0-6bfc-930b-9fbcb01c201a.png)

![aws-waf_sql-injection_2015120418-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/14cd9731-1cd5-6e62-a8cf-17551086c621.png)


以上で設定完了です。

