---
title: AWS SDK for Ruby バージョン 2 を使用したS3バケットへのオブジェクトアップロード
date: 2016-08-23
tags: AWS,ruby
author: kohei
ogp:
  og: 'プログラミングのお勉強をしようと思い、AWS公式ドキュメントにある「AWS SDK for Ruby を使用したオブジェクトのアップロード」を参考にファイルアップロードを行うRubyスクリプトを書いてみました。'
---

# はじめに
プログラミングのお勉強をしようと思い、AWS公式ドキュメントにある[「AWS SDK for Ruby を使用したオブジェクトのアップロード」](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/UploadObjSingleOpRuby.html)を参考にファイルアップロードを行うRubyスクリプトを書いてみました。
とはいえ、そのままだとただのコピペになってしまうので、アップロードするのに必要な権限のみを持つIAMユーザーを作成し、それをスクリプト内で指定してファイルのアップロードを行いたいと思います。


<br>
# 1. ファイルアップロード先の準備
「S3」→「バケットを作成」でアップロード先となるバケットを作成します。
一応、今回はリージョンを「Tokyo」にしています。
![1-s301.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9467a12e-d512-e23a-7c76-f9a541e1eb76.png)

![1-s302.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bdc1e8ef-6d6e-6c06-52ab-bc384be83e02.png)


<br>
# 2. アップロードユーザーの用意
「IAM」→「ユーザー」→「新規ユーザーの作成」で今回利用するアップロード用のユーザー名を入力し「作成」をクリックします。
![2-iam01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/c3fdf8ba-b84a-b1b0-8a24-3a7302a8577b.png)

ここで、**アクセスキーID**と**シークレットアクセスキー**が表示されるので、メモまたはダウンロードをしてから「閉じる」をクリックしてください。後で必要になります。
![2-iam02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/2fd87e9f-ccf7-99f9-4e0b-eeefc1f3b80a.png)

次に、先ほど作成したユーザーを選択します。
![2-iam03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/ab0e379b-b43a-82a9-0967-137d41867186.png)

「アクセス許可」→「インラインポリシー」→「ここをクリックしてください。」をクリックします。
![2-iam04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f769ec9e-7b96-ffc6-64ad-39f656bdbae7.png)

「カスタムポリシー」を選んで「選択」をクリックします。
![2-iam05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/67481f69-69f8-a042-9449-05cf19e679bf.png)

以下のポリシーを適用します。(コピペでOKです。)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1471591778000",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
```


![2-iam06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f5d54ce1-971c-ead6-2948-f1c791dfb19b.png)

![2-iam07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/93c5946d-9996-1c5c-864c-01cece33cfca.png)

以上で、ファイルアップロード用ユーザーが作成できました。


<br>
# 3. スクリプトの作成
それではいよいよアップロード用のスクリプトを作成します。
今回の作業環境はMacで行います。

```bash:ファイル作成
$ vim upload.ruby
```

ファイルを開いたら以下のスクリプトをコピペします。
ただ、その際に**bucketname**、**objectname**、**uploadfile**と**アクセスキーID**と**シークレットアクセスキー**は適宜変更してください。
また、バケットのリージョンをTokyoにしなかった場合も適切なリージョンに変更する必要があります。

```rb:upload.ruby
#!/usr/bin/env ruby

require 'aws-sdk'

bucketname = "kohei-no-bucket"  // バケット名
objectname = "ceresso.png"      // アップロード後のファイル名
uploadfile = "ceresso.png"      // アップロードするファイル名

Aws.config[:credentials] = Aws::Credentials.new(
  '********************',                        // アクセスキーID
  '****************************************',    // シークレットアクセスキー
)
s3 = Aws::S3::Resource.new(region:'ap-northeast-1')  // Tokyoリージョン
obj = s3.bucket(bucketname).object(objectname)
obj.upload_file(uploadfile)
```

最後に、作成したら実行権限をつけておきましょう。

```bash:権限追加
$ chmod +x upload.png
```

あと、もし*aws-adk*のインストールがまだの場合は以下のコマンドでインストールもしておいてください。

```bash:インストール
$ gem install aws-sdk
```

ということで、すべての準備が整いました。


<br>
# 4. 実践！
それではアップロードしてみます。

```bash:アップロード
$ ./upload.ruby
```

何もエラーなくプロンプトが返って来れば無事アップロード成功です。


<br>
# 5. 確認
それではバケットを確認してみます。

![3-upload01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/62b9865a-e187-ba56-a6f1-a81c4143c754.png)

アップロードできているのが確認できました。


<br>
# おわりに
今回は同じディレクトリ内にあるファイルをアップロードしました。
別の場所にあるファイルをアップロードしたい場合は、スクリプト内の*uploadfile*をパス指定すればOKです。

