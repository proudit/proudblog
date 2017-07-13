---
title: "Route53 でDNSフェイルオーバーを設定する。"
date: 2017-07-13
tags: AWS, Route53
author: kohei
ogp:
  og: 'Route53を使ってDNSフェイルオーバー機能を設定しました。'
---

# はじめに
Route53を使ってDNSフェイルオーバー機能を設定しました。
![サーバーレス.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bed5a2df-6a2c-a559-3bd9-65b0d60391ea.png)


<br>
# 1. ヘルスチェックの作成
ヘルスチェックは各サーバに対して作成します。

まずは *Web1* から。
**[Route53] > [Health checks] > [Create health check]** で作成画面へ移動します。

- **Configure health check**：ヘルスチェック名を設定する部分です。
任意の値を設定する必要があるので、*Web1*用のは 「*failover-1*」 にします。

![helthcheck-01-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c2cda956-707a-bfde-d965-c79849b8f309.png)
<br>

- **Monitor an endpoint**：チェック対象とその方法について設定する部分です。
指定したURLに対しHTTPで確認する設定にします。

![helthcheck-01-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/988c4807-2dbe-c211-c6fa-48e9bd038caf.png)

![helthcheck-01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9446a67f-fe36-bceb-0ca9-ecb36b60e11b.png)


**[Next]** をクリックすると **alarm** の設定になりますが、今回はデフォルト(*No*)にしておきます。

![helthcheck-03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7616378f-53d3-83ed-1278-db51b7912e9d.png)

あとは **[Create health check]** をクリックして完了です。

次は *Web2* に対してですがチェック先が変わるだけで基本となる設定は同じです。

![helthcheck-02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/5dc9f0ce-12f2-e0fd-4076-81a5f42083f0.png)


以上でヘルスチェックの作成は完了です。


<br>
# 2. レコード設定
**Primary** と **Secondary** の２つのレコードを作成します。今回は *Web1* を
 **Primary**、 *Web2* を **Secondary** として設定して行きます。

レコードの作成は **[Route53] > [Hosted zones] > [Domain Name] > [Create Record Set]** から行います。

それでは **Primary**レコードから設定していきます。

今回は *failover.proudit.jp* というレコードを使って設定していきます。
<img width="421" alt="recordset-01.png" src="https://qiita-image-store.s3.amazonaws.com/0/82090/c0dd3e6a-f5d2-022d-020b-fad9139a084d.png">


次に、レコードとEC2への紐づけです。 *Value* に *Web1* のIPを設定します。

そしてここからがフェイルオーバーの設定になります。
*Routing Policy* を **Failover** に設定し、*Failover Record Type* は 
 **Primary** に設定し、*Set ID*はデフォルトのままで大丈夫です。

![recordset-02-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ce00dc82-b425-6f85-3c4c-1a89086c1e47.png)

そしてフェイルオーバーの設定を入れたいので **Routing Policy** をFailoverにします。
まずはプライマリの設定なので **Failover Record Type** は Primary を選択します。
**Set ID** は勝手に設定されるのでそれでOKです。

![recordset-02-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/399489dc-a12a-906f-80b0-4328b7199757.png)


そしてここがポイントです。 *Associate with Health Check* を **Yes** にし、 *Health Check to Associate* を先ほど作成したヘルスチェック(failovertest-1)に設定します。

![recordset-02-3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e1ac40eb-eb11-71ec-0e89-d137d7fffd72.png)


Primaryが完了したらSecondaryの作成です。
*Routing Policy* を **Failover** にしたあと、 *Failover Record Type* で **Secondary** を選択します。 *Set ID* はそのままで大丈夫です。

![recordset-03-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1b1bf86a-d190-3690-d89e-b64eec5b06c5.png)

*Associate with Health Check* を **Yes** にし、今度は *Health Check to Associate* を今度は **failovertest-2** に設定します。

![recordset-03-3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e19eb9de-3bd3-74b0-ea75-071e4686356d.png)

以上で完了です。


<br>
# 確認
実際に動作確認してみます。

ヘルスチェックが正常な状態でアクセスすると「**Web1**」の文字が表示されます。

それではWeb1のapacheを停止してヘルスチェックをUnhealthyにします。

```bash:apache停止
$ sudo service httpd stop
Stopping httpd:                                            [  OK  ]
```

![helthcheck-05-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1462e46d-323c-2558-08d0-04f858441e58.png)

しばらくして更新すると「**Web2**」へ切り替わるのが確認できます。
また、Web1のapacheを起動するとHealthyに戻るのでフェイルバックします。

```
$ sudo service httpd start
Starting httpd:                                            [  OK  ]
```

![helthcheck-06-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/d5cd0704-4c5b-a8a7-262a-33bac57069ae.png)

ということで確認できました。

# おわりに
今回はわかりやすくEC2を２台用意して切り替えを確認しましたが、PrimaryをELBにしてWebサーバー2台に対してロードバランシングさせ、SecondaryをS3にすることで、サーバーがダウンした際のSorryページを表示などに利用することもできると思います。

