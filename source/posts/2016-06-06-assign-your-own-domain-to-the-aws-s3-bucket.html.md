---
title: AWS S3バケットに独自ドメインを割り当てる。
date: 2016-06-06
tags: IDCFクラウド, S3, route53 
author: kohei
---

# はじめに
---

AWS S3に作成したバケットに対して独自ドメインの割り当てを行います。

これによって静的サイトであればS3のみで完結するため、そこら辺のサーバーを動かすよりも低コストで高安定なサイト運営が可能となります。

## 前提条件
```
今回利用する独自ドメインがRoute53にてドメイン管理できることを前提に行います。
また、今回割り当てるドメインは「hogehoge.hengjiu.jp」で行います。
```

<br>
# バケットの作成 - S3
---

・S3の「バケットを作成」で新規にバケットを作成します。
![s3_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/72f93b5a-c551-b7bc-7bb9-bf2423206291.png)

・作成したバケットのプロパティで「ウェブサイトのホスティングを有効にする」に変更して保存します。
![s3_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1251fb2c-2e53-a280-36c8-77361267f69f.png)


<br>
# ドメイン登録 - Route53

・Route 53のHosted zones で対象のDomain Nameをクリックします。
![route53_01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1214fea9-685d-02f7-5fd5-8c249b676388.png)

・Create Record Setをクリックします。
![route53_02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ea7ff1e8-4f73-dd82-360f-007c955afd1e.png)

・Nameにサブドメイン(hogehoge)を入力し、AliasをYesにしてAlias Target入力状態にするとS3で作成したバケット名「hogehoge.hengjiu.jp」が表示されるので、それを選択して「Create」をします。
![route53_03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a6859d8d-4df8-a564-f4f2-939aee13ba24.png)

以上で完了です。


<br>
# おわりに
---
S3バケットに独自ドメインを割り当てるためには「バケット名は割り当てるドメイン名と同じにする」ということに注意が必要です。

もし、レコード作成時に作成したバケットが表示されない(_No Targets Available_)場合は、

・作成したバケットの名前間が違う。
・ウェブサイトホストティングが有効になっていない。

などが考えられるのでもう一度確認してみてください。

また、割り当てる際の作業手順は今回説明したように（S3でバケット作成 → Route53でレコード登録）で行うが良いと思います。
ですが、どうしても先にレコード登録をする必要がある場合は、Alias Targetに「s3-website-ap-northeast-1.amazonaws.com.」を入力すれば事前に作成しておくことが可能です。
