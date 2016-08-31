---
title: AWS SDK for Ruby バージョン 2 で期限付きURLの発行
date: 2016-08-31
tags: AWS,Ruby
author: kohei
ogp:
  og: '前回、「AWS SDK for Ruby バージョン 2 を使用したS3バケットへのオブジェクトアップロード」でS3へオブジェクトのアップロードを行いました。
でも、このままではアップロードしただけで、誰もアップしたオブジェクトにアクセスができないですね。。。
ということで、今回はアップロードしたファイルをブラウザからアクセスできるように「期限付きURLの発行」をしてみたいと思います
。'
---

# はじめに
前回、[「AWS SDK for Ruby バージョン 2 を使用したS3バケットへのオブジェクトアップロード」](http://blog.proudit.jp/2016/08/23/to-upload-a-file-using-the-aws-sdk-for-ruby.html)でS3へオブジェクトのアップロードを行いました。
でも、このままではアップロードしただけで、誰もアップしたオブジェクトにアクセスができないですね。。。
ということで、今回はアップロードしたファイルをブラウザからアクセスできるように**期限付きURLの発行**をしてみたいと思います。
ちなみに**期限付きURL**とはその名の通り、URLを発行してから１0分だったり3日だったり１週間だったりと、利用できる**期限**を持たせたURLです。

<br>
# 1. アクセス先の準備
前回、[「AWS SDK for Ruby バージョン 2 を使用したS3バケットへのオブジェクトアップロード」](http://blog.proudit.jp/2016/08/23/to-upload-a-file-using-the-aws-sdk-for-ruby.html#1.-ファイルアップロード先の準備)で作成したバケットを利用するので今回は省略します。

<br>
# 2. アクセスユーザーの用意
まずは、バケットへアクセスできるユーザーを準備しますが、[前回作成](http://blog.proudit.jp/2016/08/23/to-upload-a-file-using-the-aws-sdk-for-ruby.html#2.-アップロードユーザーの用意)した*kohei-no-iam*を利用したいと思います。

まずは「アクセス許可」→「ポリシーのアタッチ」をクリックします。

![4-iam01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6a324b60-8cfd-05c8-a9ea-3a6450c39f25.png)

今回は **AmazonS3ReadOnlyAccess** をアタッチするだけでOKです。

![4-iam02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/3d1435a3-6637-f5f9-ef80-6ba87388d897.png)

![4-iam03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b6d48db2-01be-4bfb-0b9b-20cb21f7ff70.png)

以上でユーザーの用意は完了です。


<br>
# 3. スクリプトの作成
それではスクリプトを作成します。

```bash:スクリプト作成
$ vim presigned_url.rb
```

ファイルを開いたら以下の内容をコピペします。
また、その際に**bucketname**、**objectname**、**uploadfile**と**アクセスキーID**と**シークレットアクセスキー**は適宜変更してください。
バケットのリージョンをTokyoにしなかった場合も適切なリージョンに変更する必要があります。

```rb:presigned_url.rb
#!/usr/bin/env ruby

require 'aws-sdk'

bucketname = "kohei-no-bucket"    # バケット名
objectname = "ceresso.png"        # オブジェクト名

Aws.config[:credentials] = Aws::Credentials.new(
  '********************',                      # アクセスキーID
  '****************************************',  # シークレットアクセスキー
)
s3 = Aws::S3::Resource.new(region:'ap-northeast-1')  # Tokyoリージョン
obj = s3.bucket(bucketname).object(objectname)
puts obj.presigned_url(:get, expires_in:60)   # expires_in:有効期限(秒)
```

実行権限を追加しておきます。

```bash:権限追加
$ chmod +x presigned_url.rb
```

以上で準備完了です。


<br>
# 4. 実践！
その前に、一応現在のバケットの設定が**「ウェブサイトのホスティングを有効にしない」**となっているのを確認しておきます。

![5-test01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/18fb2061-a1fc-f7d5-fee6-0f8e7b15e7b8.png)


それでは実行です。

```bash:URL発行
$ ./presigned_url.rb
https://kohei-no-bucket.s3-ap-northeast-1.amazonaws.com/ceresso.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊＊%2F20160824%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20160824T061832Z&X-Amz-Expires=60&X-Amz-SignedHeaders=host&X-Amz-Signature=26eddaaad67a9f0e5d011b110ee34e271557c5f9f8bac82c9da655d58956245e
```

発行されたURLにアクセスしてみます。

![5-test02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6d3642fe-2325-e9f2-54b3-d093f67a472b.png)

画像が表示されました。
それでは60秒過ぎてからもう一度アクセスしてみます。

![5-test03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/0a7cf754-86eb-631e-0de4-2b20b78e389f.png)

アクセスができなくなっているのが確認できました。
以上で期限付きURLの発行の完了です。


<br>
# おわりに
「期限付きURL」が発行できることによって、一時的なファイル共有が可能になるのでこれはとても便利なんじゃないかなと個人的には思います。
ただ、[ドキュメント](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Object.html#presigned_url-instance_method)によるとこの期限付きURLは「１週間」を超える設定にはできないことです。

> Raises:
(ArgumentError) — Raised if :expires_in exceeds one week (604800 seconds).


<br>
# おまけ
そこについても試してみました。

```bash:ちょうど1週間(604800秒)の場合
$ ./presigned_url.rb 
https://kohei-no-bucket.s3-ap-northeast-1.amazonaws.com/ceresso.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=********************%2F20160825%2Fap-northeast-1%2Fs3%2Faws4_request&X-Amz-Date=20160825T021333Z&X-Amz-Expires=604800&X-Amz-SignedHeaders=host&X-Amz-Signature=709a0de7cf14bd002a9b7953da5e5c9433104ccf9743bb7fda0332bd17830043
```

```bash:1週間+1秒(604801秒)の場合
$ ./presigned_url.rb 
/Library/Ruby/Gems/2.0.0/gems/aws-sdk-core-2.5.4/lib/aws-sdk-core/s3/presigner.rb:68:in `expires_in': expires_in value of 604801 exceeds one-week maximum (ArgumentError)
	from /Library/Ruby/Gems/2.0.0/gems/aws-sdk-core-2.5.4/lib/aws-sdk-core/s3/presigner.rb:50:in `presigned_url'
	from /Library/Ruby/Gems/2.0.0/gems/aws-sdk-resources-2.5.4/lib/aws-sdk-resources/services/s3/object.rb:189:in `presigned_url'
	from ./presigned_url.rb:14:in `<main>'
```

期限付きURLも期限付きだったんですねw

参考：[**AWS SDK for Ruby - presigned_url**](http://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Object.html#presigned_url-instance_method)

