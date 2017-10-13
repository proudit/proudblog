---
title:[AWS Organizations]アカウントの統合とaccount nameの編集方法
date: 2017-10-13
tags: AWS,
author: ayako
ogp:
  og:
    description: ''
---


以前の記事ではOrganizationsでの新規アカウント作成方法についてご紹介しました。
既に管理しているアカウントは大方統合済みなのですが、まだ管理されていないアカウントを今回は追加で統合しました。
その際の手順を備忘録としてまとめます。

▼前回の記事はこちら▼
[AWS Organizationsでアカウントの新規作成とログイン時の注意点
](http://qiita.com/ai-2723/items/d82d072debdbf6d15b34)

#複数アカウントの一括管理
---

分かりやすく一言で言ってしまえばOrganizationsは複数アカウントの一括管理を可能にするもの。
一括請求はもちろんのこと、グループごとのポリシー管理が可能。

#アカウントの統合方法
---

1.
親アカウントでコンソールにログインし、[Organizations]から統合したい子アカウントに対して招待を送ります。

![スクリーンショット 2017-10-13 14.20.06.png](https://qiita-image-store.s3.amazonaws.com/0/174392/51e0ba7a-3d7b-638f-0c9f-383f8bc0a7c7.png)

2.
子アカウントのコンソールへログインし、招待の承認をします。

左下の[invitation]をクリック。

![アカウント統合03.png](https://qiita-image-store.s3.amazonaws.com/0/174392/797ec632-12c0-2429-9e3b-efd797fd9d47.png)

内容に相違なければ[Accept]。

![アカウント統合04.png](https://qiita-image-store.s3.amazonaws.com/0/174392/c19c7753-1a63-5822-7f09-2e97c8bc4e5f.png)


以上で、完了です。
再度親アカウントでログインしOrganizationsで一覧を確認すると、都合したアカウントの表示が確認できます。

#Account nameの編集方法
---

統合が完了し、Organizationsで管理されているアカウントの一覧を見てみると一部のアカウントにAccountnameの表示がない！
ここが空欄になっている事で、請求情報のアカウント毎表示が数字のみのID表示になってしまっていて分かりにくいんですよね。。

![organizationsアカウント名なし.png](https://qiita-image-store.s3.amazonaws.com/0/174392/30ab4e6a-af3c-deb6-ec9b-8e00dd7f87ff.png)

と言う事で、編集してみました。

1.
編集を行いたいアカウントでコンソールへログイン。
右上の[AWSようこそ]のタブ＞[アカウント]

![アカウント表示名変更01.png](https://qiita-image-store.s3.amazonaws.com/0/174392/02c42903-4f02-a072-23ec-9abf23a1365c.png)

アカウント設定画面右上の[編集]をクリック。

![アカウント表示名変更02.png](https://qiita-image-store.s3.amazonaws.com/0/174392/405cee28-9d5f-4bef-d932-649067510645.png)

[Edit]ボタンを押して編集して[Done]。

![アカウント表示名変更03.png](https://qiita-image-store.s3.amazonaws.com/0/174392/6e759be4-7856-7970-6ccb-f39362faab63.png)

以上で、編集が完了しました。

![アカウント表示名変更04.png](https://qiita-image-store.s3.amazonaws.com/0/174392/a9c6505e-7933-a309-1bd2-9443d4aee1d4.png)


#おわりに
---
これで請求は一つに統合され、account nameの表示がされた事で見やすくなりました！
ここからさらに管理しやすくできないか、erganizationsについて引き続き調べてみようと思います。
