---
title: AWS Certificate ManagerでSSLを作成する際に送る承認リクエストの送信先をスーパードメインに変更する。
date: 2016-11-21
tags: AWS, CertificateManager, aws-cli
author: kohei
ogp:
  og: 'AWS Certificate ManagerでSSLを作成する際、メールで送られてくる承認リクエストを認証が必要となります。'
---

# はじめに
_AWS Certificate Manager_でSSLを作成する際、メールで送られてくる承認リクエストを認証が必要となります。
基本的に承認リクエストの送信先となるのは、

- WHOIS ルックアップで得られるドメインの登録者、管理者、および技術担当者の連絡先
- ドメイン名の前に admin@、administrator@、hostmaster@、webmaster@、および postmaster@ を付加して生成された 5 つの特別なメールアドレス

となります。

例えば**stg.proudit.jp**を取得する場合は、

- 「proudit.jp」で得られるwhois情報のメールアドレス
- stg.proudit.jpドメインの前がadmin@, administrator@, hostmaster@, webmaster@

この５つに対して送られます。

ですがもし、[Whois情報公開代行](https://help.onamae.com/app/answers/detail/a_id/8598)を行なっている場合**@stg.proudit.jp**のアドレスにしか承認リクエストが送られません。
そんな時、_aws-cli_を利用すると**@stg.proudit.jp**を**@proudit.jp**変更して承認リクエストを送ることができます。


<br>
# SSLについて
ちょっとその前に、軽くドメインについて説明しておこうと思います。

- **ドメイン認証型(DV:Domain Validation)**

>SSL証明書申請者が申請したドメイン使用権を有しているかを認証します。
認証確認はメールで行われるため、組織情報の確認や認証局の電話確認はありません。
そのため証明書の発行は早く、価格も安く発行できるため手頃ですが信頼性は３つの中で一番低くなります。
また、この認証はクイック認証型とも呼ばれます。

![dv.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ea557008-6745-f649-39f9-760cc49ce502.png)


- **企業実在認証型(OV:Organization Validation)**

>証明書に記載されている組織が法的に実在するかを確認し、さらにその組織が証明書に記載されているドメインの所有者であるかを確認します。
確認方法としては、ドメインの所有者をWHOIS情報で確認したあと、組織が法的に実在することを第三者データベースに照会して確認します。
さらに第三者データベースに登録されている代表電話番号に電話して本人確認を行います。
ドメイン認証と比べ、信頼性は高くなりますが価格も高くなります。

![ov.png](https://qiita-image-store.s3.amazonaws.com/0/82090/df0f6100-856e-8f7f-db63-bbc82999d79d.png)


- **EV認証(EV:Extended Validation)**

>証明書に記載されている組織が法的に実在するかを確認し、さらにその組織が証明書に記載されているドメインの所有者であることを確認します。
確認方法としては、実在認証型の確認に加えて公的書類(登記事項証明書)での確認も行います。
審査が厳しいため発行に1〜2週間ほどかかり価格も高くなりますが、その代わり信頼性は一番高くなります。

![ev.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ea0fb5d7-64f9-0d18-b2ee-0892618579c6.png)


とりあえず、ポイントとなりそうなのを表にしてみました。

|           |ドメイン認証型 |企業実在認証型 |EV認証型       |
|:---------:|:---------:|:-----------:|:------------:|
|価格       |安め         |高め         |もっと高め       |
|発行スピード  |即日        |だいたい2〜3日 |だいたい1〜2週間 |
|信頼性     |低          |中           |高             |
|審査内容   |メール |whois, 第三者データベース, 電話|登記事項証明書, whois, 第三者データベース, 電話|

ということで、今回の_Certificate Manager_で作成できるのは**ドメイン認証型**になります。


<br>
# SSL作成
ということでやっとSSLの作成を行いたいと思います。
まず初めに、ベースドメイン名を指定せずに単純にSSLを作成する場合に行うcliコマンドが以下です。

```bash:一般的なSSL作成
$ aws acm request-certificate --domain-name stg.proudit.jp
```
_--domain-name_にドメイン名を指定してあげることで承認リクエストを送ることができます。
ただ、この場合の承認リクエストは**@stg.proudit.jp**へ送られてしまいます。
これを**@proudit.jp**へ変更するには_--domain-validation-options_オプションを利用します。

```bash:ベースドメインを変更したSSL作成
$ aws acm request-certificate \
    --domain-name stg.proudit.jp \
    --domain-validation-options DomainName=stg.hengjiu.jp,ValidationDomain=hengjiu.jp \
    --region us-east-1
```

_DomainName=_には今回作成するドメイン(_--domain-name_オプションで指定したドメイン)を、_ValidationDomain=_にその**スーパードメイン**(そのドメインの上位階層に位置しているドメイン)を与えます。
ここで_--region us-east-1_とオプションでリージョン指定していますが、CloudFrontに導入したい場合はバージニアでないと利用できないためです。だって、_Certificate Manager_が活躍できる一番の場面ってそこですよね？

ということで認証メールが届いていると思うので確認してみてください。


<br>
# おわりに
スーパードメインでしかダメなの？_ValidationDomain_全く違うドメイン(hogehoge.jpとか)にすればそっちのadmin@とかにメール送られたりするんじゃないの？
と思うかもしれませんが、それはありません。

>**Q: 証明書の承認リクエストの送信先となる E メールアドレスを設定できますか?**
いいえ。ただし、検証メールの送信先とするベースドメイン名を設定することはできます。ベースドメイン名は、証明書リクエストに記載されたドメイン名のスーパードメインである必要があります。例えば、server.domain.example.com の証明書をリクエストする場合、AWS CLI や AWS API を使用して、承認メールを admin@ domain.example.com に転送するよう設定できます。詳細については、ACM CLI リファレンスおよび ACM API リファレンスをご覧ください。
ー出典：[AWS Certificate Manager よくある質問](https://aws.amazon.com/jp/certificate-manager/faqs/)

ちゃんとAWSのFAQにも載っています。そりゃそうですよね。認証の意味がなくなってしまいますよねw

ですが、これができるだけで、いちいちサブドメ単位でメールアドレスを設定しないで済むので知っておくとちょっぴり便利になると思います。
