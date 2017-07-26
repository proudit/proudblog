---
title: AWS Organizationsでアカウントの新規作成とログイン時の注意点
date: 2017-07-26
tags: AWS,
author: ayako
ogp:
  og:
    description: ''
---

#AWS Organizationsとは
---

複数のAWSアカウントを統合するためのアカウント管理サービス。
社内では主にメンバーアカウントの請求をまとめるために利用していますが、
各アカウントに対してのサービスのアクセス制限も可能。

今回、新規案件用にアカウントを取得するためアカウントを作成する必要があったのですが、、
ちょっとした勘違いで初めてOrganizationsからアカウントの作成を行いました。

#AWS Organizationsを使って、アカウント作成してみる
---

コンソールのトップページ右上から[自分の組織]をクリック。

![AWS-OZ01.png](https://qiita-image-store.s3.amazonaws.com/0/174392/cb8a675d-d254-4f98-2df7-99cd35f86d7b.png)

[Accounts]　＞　[Add account]

![AWS-OZ02.png](https://qiita-image-store.s3.amazonaws.com/0/174392/32d55a27-2759-196c-609a-d77c131a0df6.png)

今回は新規アカウントの作成なので[Create account]を選択。
必要事項を入力し、Createするとアカウントが作成されます。

![AWS-OZ03.png](https://qiita-image-store.s3.amazonaws.com/0/174392/04472f34-e19f-e555-044a-f0a12c42b323.png)

これで作成は完了です。
通常アカウント作成の際に必要となる、


 - クレジットカード情報の入力
 - AWSから電話があり、伝えられた認証コードを入力する

といった作業がないので、社内で権限がないメンバーにも気軽に作成を依頼することができそうです。

#Organizationsでアカウントを作成する際の注意点
---

ただし、注意点もあります。

AWS Organizations を使用して作成した場合、新しいアカウントの初期パスワードはルートユーザーに割り当てられません。そのため、ルートユーザーとしてアカウントに初めてアクセスする場合は、アカウントのパスワード復旧プロセスを行う必要があります。
[引用元：組織のメンバーアカウントへのアクセスと管理
](http://docs.aws.amazon.com/ja_jp/organizations/latest/userguide/orgs_manage_accounts_access.html)

そう、Organizationsからアカウントを発行する場合パスワード設定箇所がどこにもありません。

アカウントを取ることはできても、PWが設定されていないので、
ログインすることができません。
上記の方法を使ってパスワードの設定が必要です。ご注意ください。

なぜアカウントの作成が可能なのにPWの設定ができないのか....？
Organizatipnsで子アカウントのPWを統一はできないのか...
若干不便な気もします。今後改善するのだろうか...



