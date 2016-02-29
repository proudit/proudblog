---
title: S3の特定バケットへのアクセスを特定のCloudFrontからのみ許可する。
date: 2016-02-29
tags: AWS,S3,CloudFront
author: kohei
---

# はじめに
---
S3内のコンテンツをCloudFrontを使って配信する際に、直接外部からS3へアクセスすることは制限しつつ、CloudFrontを通してはアクセスができるという設定をしてみました。
![cloudfront.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fe714aba-8e94-9770-a027-363c8df5c887.png)

今回は拡張子が「.png」のアクセスがあった場合にS3へ振り分ける設定を入れ、さらにCloudFrontからのみしかそのバケットへはアクセスできないようにします。

<br>
<br>
# 設定
---
# 1.S3の設定
## 1-1.バケットを作成しコンテンツをアップロードします。
今回はバケット名を「from-cloudfront-to-s3-test」とし、コンテンツには「[test.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a5df31b8-3ffc-c3f6-1c0a-cc8f417d5595.png)
」を利用します。

<br>
## 1-2.アップロードしたコンテンツへブラウザからアクセスし、閲覧できないことを確認します。
![20151127_S3_Object-2-URL.png](https://qiita-image-store.s3.amazonaws.com/0/82090/824af88a-474f-ca3c-3ae5-04dbbe844822.png)

それでは設定をしてみます。

<br>
<br>
# 2.サービス画面の表示
## 2-1.コントロールパネルの「Services」から「CloudFront」を選択します。

<br>
<br>
# 3.Originの作成
## 3-1.対象の「Distribution」にチェックをし「Distribution Settings」を選択します。
![20151127_CloudFront_Distributions-1-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/74d6f3e6-470a-dacc-ab61-f3de4cda5167.png)

または対象のIDをクリックでもOKです。
![20151127_CloudFront_Distributions-1-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ff0c0667-2658-a7b7-1e70-0197841330d0.png)

<br>
## 3-2.タブ「Origins」を選択し「Create Origin」をクリックします。
![20151127_CloudFront_Distributions-2-1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6123ef8c-4733-c858-8af3-96de868854de.png)

<br>
## 3-3.「Origin Domain Name」を今回準備したS3バケット(from-cloudfront-to-s3-test)に設定します。

<br>
## 3-4.「Restrict Bucket Access」を[Yes]を選択します。
　すると「Origin Access Identity」、「Comment」、「Grant Read Permission on Bucket」の項目が現れます。

<br>
## 3-5.現れた項目に対し以下の内容を選択または入力します。
　・「Origin Access Identity」→「Create a New Identity」を選択。
　・「Comment」→「access-idenntity-s3-access-test」と入力。
　・「Grant Read Permission on Bucket」→「Yes,Update Bucket Policy」を選択。
![20151127_CloudFront_Distributions-2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/08f33b7c-2600-3119-a6d5-7ed4d9451479.png)

<br>
## 3-6.「Create」をクリックすると一覧に作成した「Origin」がリストされます。
![20151127_CloudFront_Distributions-3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3dce78d7-147c-4c21-47fc-def1d8221c22.png)

<br>
<br>
# 4.Behaviorの作成
## 4-1.タブ「Behaviors」を選択し、「Create Behavior」をクリックします。
![20151127_CloudFront_Distributions-4.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9ba8b1d0-2272-8910-46ef-1f48b4dd416a.png)

<br>
## 4-2.「Path Pattern」を「/*.png」と入力し、「Origin」は「S3-from-cloudfront-to-s3-test」を選択します。(今回はその他はデフォルトのままにします。)
![20151127_CloudFront_Distributions-5.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1acb3e83-61e7-f08a-ccbe-8e63c649ba63.png)

<br>
## 4-3.「Create」をクリックすると一覧に「Behavior」がリストされます。
![20151127_CloudFront_Distributions-6.png](https://qiita-image-store.s3.amazonaws.com/0/82090/35529fce-f03e-79f4-3934-7f7ceeee8a61.png)

<br>
<br>
# 5.反映確認
## 5-1.左サイドばーの「Distributions」または中央画面上部の「CloudFront Distributions」をクリックします。
![20151127_CloudFront_Distributions-8.png](https://qiita-image-store.s3.amazonaws.com/0/82090/cd0f808c-7707-81bf-5c6b-7dbe57b02344.png)

<br>
## 5-2.「Status」項目が「In Progress」となっているのが確認できます。
![20151127_CloudFront_Distributions-7.png](https://qiita-image-store.s3.amazonaws.com/0/82090/a49a403e-f9dd-24e7-dc9d-90ba733f40f7.png)

<br>
## 5-3.しばらく時間が経つと「Status」項目が「Deployed」となったら反映完了です。
![20151127_CloudFront_Distributions-9.png](https://qiita-image-store.s3.amazonaws.com/0/82090/44969d00-4da2-7b18-8b37-5b5af8ad623a.png)

<br>
## 5-4.CloudFront経由で「/test.png」へアクセスするとS3にアップ画像が表示されます。
![20151127_CloudFront_Distributions-10.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8e699ee8-3d5e-a60a-2b78-5969d5db10bc.png)
「CloudFront Distribution」画面からタブ「General」をクリックすると「Domain Name」が確認できるので、今回の場合はそれに続けて「/test.png」を入力してあげればOKです。

<br>
<br>
# おまけ
---
念のため、アップした際のS3の「Link」をアクセスすると「AccessDenied」の画面が表示されます。
![20151127_S3_AccessDenied.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f4bea7a8-eac1-b675-5aba-113a087cd7ad.png)

また、バケットのPermissionについても確認してみます。
![20151127_S3_Object-3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6a189140-e7dc-f8cd-eb53-df868a4fc5fc.png)
「Edit bucket policy」をクリック。
![20151127_S3_Object-4.png](https://qiita-image-store.s3.amazonaws.com/0/82090/76320baf-0338-33c5-cb50-3149af4f5b5b.png)
CloudFrontの「from-cloudfront-to-s3-test」からアクセスができる設定が入っているのを確認できます。この設定はCloudFrontの「Origin」作成時に、「Grant Read Permission on Bucket」を[Yes]にすると追加されます。

また、「from-cloudfront-to-s3-test」はCloudFrontの「Origin Access Identity」で確認できます。
![20151127_CloudFront_AccessIdentity-5.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ed3ccb5d-d4f6-9a9a-0ab9-a9b318dc8e30.png)
これもCloudFrontの「Origin」作成時に「Origin Access Identity」を[Create a New Identity]にすることで今回は新規に作成しています。

ということでアクセス許可設定が完了しました。

