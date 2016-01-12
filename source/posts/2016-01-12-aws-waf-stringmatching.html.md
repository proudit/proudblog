---
title: 「AWS WAF」を導入してみた。- String matching編
date: 2016-01-12
tags: AWS, WAF, CloudFront
author: kohei
---

# はじめに
---
2015年のre:Inventで「AWS WAF」が発表されました。

AWS WAFはアプリケーション用のファイアウォールで、IP address、SQL injection、String matchingに関するアクセスの制御ができます。
ただ、このサービスを利用するにはCloudFront経由でのアクセスにしか対応していないため、ELBやEC2にWAFを導入する場合はCloudFrontを配置する必要があります。

今回は既に作成済みの「waf-test-acl」にString matchingの設定を追加してみます。
その他の設定については以下参照ください。
[「AWS WAF」を導入してみた。- IP addresses編](../../../2015/12/28/aws-waf-ipaddress.html)
[「AWS WAF」を導入してみた。- SQL injection編](../../../2016/01/07/aws-waf-sqlinjection.html)


# 1.設定
---
## ① Conditionの作成
まず、String matchingをクリックします。
![aws-waf_sql-injection_2015120401.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3c0e488c-ab1e-ed97-73ef-5f8b66a183ef.png)

「Create condition」をクリックします。
![aws-waf_sql-injection_2015120402.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a8744128-6c9f-e323-dc85-8ca16f70d176.png)

「Name」には任意のコンディション名を入力します。
また、Filter settingsの「Part of the request to filter on」でチェックしたいWeb要求、Match typeは部分一致や完全一致といった条件、「Transformation」でAWS WAFがリクエストをチェックする前に行う変換方式を指定。「Value is base64 encoded」は　「Value to match」にはチェックする文字列を入力します。入力が完了したら最後に「Add another filter」をクリックして条件に追加します。
![aws-waf_uri_2015121003.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6a5672a0-c18a-f7b7-ce47-386f319d2a44.png)

Filters in this string match conditionへの追加が確認できたら「Create」をクリックして作成します。
![aws-waf_uri_2015121004.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d5e64543-c90e-30d6-f8a6-18a16bb0080a.png)

<br>
## ② Ruleの作成
conditionを作成したら、次に「Rules」をクリックします。
![aws-waf_uri_2015121005.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1011c8f8-ea24-1b8d-07de-731158892085.png)

Rules設定画面が表示されたら「Create rule」をクリックしルールの作成を行います。
![aws-waf_uri_2015121006.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d38f4d02-4131-0b3e-0068-4c4de905084f.png)

先ほどConditionsのSQL injectionで作成したルールを設定し、完了したら「Create」をクリックします。
![aws-waf_uri_2015121007.png](https://qiita-image-store.s3.amazonaws.com/0/82090/58d87168-f0b6-aea0-8d6f-17e9433e7115.png)

ルールの作成が完了したら「Web ACLs」をクリックします。
![aws-waf_uri_2015121008.png](https://qiita-image-store.s3.amazonaws.com/0/82090/280aa372-ac09-ab3e-dbac-6c65969eec9b.png)

<br>
## ③ Access Control Listへの追加
今回ルールを追加する対象のACL名をクリックします。
![aws-waf_uri_2015121009.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8bc790ec-cbde-dcde-ffe1-f1f0cccf740e.png)

タブ「Rules」をクリックして「Edit web ACL」をクリックします。
![aws-waf_uri_2015121010-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c21cf4c1-f557-80f4-2e82-cc7d0edf7b86.png)

「Rules」のプルダウンで今回作成したルールを選択し、「Add rule to web ACL」をクリックします。
![aws-waf_uri_2015121011.png](https://qiita-image-store.s3.amazonaws.com/0/82090/127306be-910f-092e-fea8-1e4e097b7848.png)

すると”If a request matches all the conditions in a rule, take the corresponding action”に追加されます。今回はブロックをしたいため”Action”は「Block」をチェックし、「Update」をクリックします。
![aws-waf_uri_2015121012.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ed1925ab-f67f-b767-b99b-c5da4222b416.png)

ルールが追加されました。「Requests」タブをクリックするとリクエストログが確認できます。
![aws-waf_uri_2015121013-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/21d65f4b-572b-20b3-11d3-c4ce5df9e538.png)


<br>  
# 2.動作確認
---
今回は「test.txt」の文字列があるアクセスはブロックというルールを適用しました。なので例えば「http://<CloudFront>/test.txt」へアクセスすると以下の画面が表示されます。
![aws-waf_uri_2015121016-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2e8d2008-6169-9166-c14a-f33ed1a12fad.png)

今回作成したルールによってフィルタリングがされているかを確認するには「Requests」から今回作成した"uri-string-block-rule"をプルダウンから選び、「Get new samples」をクリックします。
![aws-waf_uri_2015121015-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1e536f40-c29a-2e19-4173-959a93b20f44.png)


<br>
# あとがき
つい先日、画面が変わったみたいです。(とりあえず2015/12/10には変わってました。)
「Requests」タブをクリックすると、マッチしたリクエストまたはルールについてのグラフが現れます。
![aws-waf_uri_2015121014.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e4b7a2f3-4a6e-5ddf-e492-3843a25b5708.png)
　確認したいリクエストやルールにチェックを入れるとそれについてグラフ化されます。もともとCloudWatchで確認できましたが、一つ一つ選択して確認しないといけなかったのと、CloudWatchの画面に移動しないといけなかったので、見やすくなってよかったかなと思います。
　また、「Sampled requests」もルールごとに表示されるように変わりました。これについてはルールごとに表示は見やすくて良いのですが「ALL」みたいな全てを表示する項目があった方がより使いやすいなと感じました。また、以前は記載されていたルールに対しての処理(BlockしたのかAllowしたのか)が無くなってしまったので、そこも直感的に分かりづらくなって残念です。
　ただWAFはリリースしたてというのもあり、今後もどんどん変化していくと思います。よりサービスの充実とともに使いやすくなることにも期待です。

