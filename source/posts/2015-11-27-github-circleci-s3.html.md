---
title: 静的HTML公開フローをサーバレスでDevOps！(Github,CircleCI,AWS S3)　前編
date: 2015-11-27
tags: AWS,GitHub,CircleCI,s3
author: toguma
---


コーポレートサイトなどの静的サイトを、Github+CircleCi+S3webhostingでサーバレスDevOpsを実現。

主な利点

* Github操作のみでデプロイを自動化。
* サーバレスなのでサーバ運用不要。
* **ステージングサイトには閲覧制限(許可IP制）**を設けることで、外部会社との連携も安全。

#構築内容
---
1. AWS S3 webhosting構築
1. Githubリポジトリ作成
1. 静的ページを用意　HTML+CSS(bootstrap)
2. CircleCIでのオートデプロイ
1. オートデプロイテスト
1. +αでフォームサイトはlambda,cognitoで実装

6は後編で掲載予定。

#想定フロー
---
1. 各自ローカル環境でHTML編集。Githubで管理。
2. stagingブランチへのgit pushでステージングサイトへ自動デプロイ 
   (ステージングサイトは自社サイトのみ閲覧可能）
2. pullreqし、レビュワーがステージングサイトをチェック
3. OKならmasterマージされ、本番サイトへ自動デプロイ
 
各フローをchatのbot機能＋chat配信機能を利用するとChatOpsにも対応可能！

#必要アカウント
---

* AWSアカウント 
* Githubアカウント 
* CircleCiアカウント 

[Github](http://github.com)アカウントはpublic公開のみなら無償。
[CircleCI](https://circleci.com)アカウントはgithubアカウントと連携するので個別に作成する必要はなし。かつ、本構成レベルの利用なら無料（正確には1コンテナまで無料）！

#想定費用
---
前述の通り、Github/CircleCiについては条件により無償枠で実現可能。

HTML分のAWS S3費用(保管費用、転送費用）一般的なサイトで**$2~3**前後
+後編の問い合わせフォーム用のlambda+cognito費用$**2~3**で実現可能。


#サイト作成例
---
今回のサイト例

* **s3site.proudit.jp**  -> 本番サイト
* **st.s4site.proudit.jp** ->　ステージングサイト

と定義して、構築例を進める。



#IAMユーザ「s3-deploy-user」の作成
---
CircleCIからのデプロイユーザを作成。

- AWSコンソールより
 - IAM->ユーザー->新しいユーザの作成
 - ユーザ名　「s3-deploy-user」で作成

<img width="375" alt="スクリーンショット 2015-11-25 10.00.08.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/4a642429-4238-bca0-6345-07dd1c44adb5.png">


　**この時認証用のAccesskey/SeacretKeyを必ずダウンロードし控えておくこと！**
　


- IAM->ポリシー作成->独自のポリシーを作成
 - ポリシー名 「s3-deploy」
 - ポリシードキュメント 

作成ポリシー例

    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::s3site.proudit.jp",
                "arn:aws:s3:::s3site.proudit.jp/*",
                "arn:aws:s3:::st.s3site.proudit.jp",
                "arn:aws:s3:::st.s3site.proudit.jp/*"
            ]
        }
    ]
    }

作成したユーザ「s3-deploy-user」に
ポリシー「s3-deploy」をアタッチする。

<img width="673" alt="スクリーンショット 2015-11-25 10.02.56.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/18479643-0cc2-4c6d-fe7f-8d03c6e993ae.png">



#S3のwebhostingを準備
---
まずは器の構築。
ここは本題ではないので、さらっと要点のみ記載。詳細は以下参照。
[Amazon S3 での静的ウェブサイトのホスティング](https://docs.aws.amazon.com/ja_jp/AmazonS3/latest/dev/WebsiteHosting.html)

今回のサイト例
**s3site.proudit.jp**  -> 本番サイト
**st.s3site.proudit.jp** ->　ステージングサイト
として、各バケットを静的ウェブサイトとして作成。

本番サイトの公開用bucketポリシーはすべて許可。
     
    {
      "Version":"2012-10-17",
      "Statement":[{
    	"Sid":"AddPerm",
            "Effect":"Allow",
    	  "Principal": "*",
          "Action":["s3:GetObject"],
          "Resource":["arn:aws:s3:::s3site.proudit.jp/*"
          ]
        }
      ]
    }
      

ステージングサイトの要件の１つ、自社からのアクセスIPからのみ閲覧許可とする、場合のポリシー例
    
    {
	"Version": "2008-10-17",
	"Id": "PolicyAccessCtrl",
	"Statement": [
		{
			"Sid": "StmtAccessCtrl",
			"Effect": "Deny",
			"NotPrincipal": {
				"AWS": "arn:aws:iam::[AWSアカウントID]:user/s3-deploy-user"
			},
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::st.s3site.proudit.jp/*",
			"Condition": {
				"NotIpAddress": {
					"aws:SourceIp": "[許可IP]"
				}
			}
		},
		{
			"Sid": "StmtAccessCtrl",
			"Effect": "Allow",
			"Principal": {
				"AWS": "*"
			},
			"Action": "s3:GetObject",
			"Resource": "arn:aws:s3:::st.s3site.proudit.jp/*",
			"Condition": {
				"IpAddress": {
					"aws:SourceIp": "[許可IP]"
				}
			}
		},
		{
			"Sid": "AllowBucketAndObjectsAccessFromCircleCI",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::[AWSアカウントID]:user/s3-deploy-user"
			},
			"Action": "s3:*",
			"Resource": "arn:aws:s3:::st.s3site.proudit.jp/*"
		}
	]
    }
    
[許可IP]
[AWSアカウントID]
は適宜代入のこと。
[AWSアカウントID確認方法はこちら](https://aws.amazon.com/jp/how-to-find-accountid/)


なお、このままだと、
[s3site.proudit.jp.s3-website-ap-northeast-1.amazonaws.com](http://s3site.proudit.jp.s3-website-ap-northeast-1.amazonaws.com)
と長いURLのままなので、Route53であればAlias設定、他ドメイン管理DNSであれば適宜cname連携しておくこと。

Route53での設定例
<img width="431" alt="スクリーンショット 2015-11-25 10.09.41.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/e035c503-0be8-53c6-c28a-56e044411e20.png">

<img width="655" alt="スクリーンショット 2015-11-25 10.11.47.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/16e74849-53ce-e14f-03f4-6588d8bfd661.png">




#githubレポジトリ準備
---
事前にGithubには該当のリポジトリを作成しておく。
例ではpublic環境であるが、もちろんprivete環境(有料）でも可。

![スクリーンショット 2015-11-24 15.49.59.png](https://qiita-image-store.s3.amazonaws.com/0/89940/cf64d802-f7b8-6503-5912-662f9dba47f2.png)
　
　

#静的サイト準備
---
既存サイトがあれば、それを利用。
今回は新規作成の例。
Bootstrapの無料テンプレート利用を利用する前提で進める。

>BootstrapとはWebサイトやWebアプリケーションを作成するフリーソフトウェアツール集である。 タイポグラフィ、フォーム、ボタン、ナビゲーション、その他構成要素やJavaScript用拡張などがHTML及びCSSベースのデザインテンプレートとして用意されている。

参考URL
[BootstrapでレスポンシブなWebサイト制作](http://gihyo.jp/design/serial/01/bootstrap3)
[最近公開されたBootstrapの無料テンプレート 180本まとめ](http://designup.jp/bootstrap-free-template-354/)


いいテンプレートが見つかったら、ダウンロードして適宜自社サイト用に編集する。
（ここでは[Colorful Flat](https://www.xtendify.com/en/themes/bootstrap/landing-pages/103-colorful-flat)というテンプレートを利用）



```bash:Githubへのup例　CLI例(適宜ツール利用可）

リポジトリ用のTopディレクトリにあらかじめダウンロードしたzipを置く。
$ cd (repo-top)/
$ unzip colorfulflat-new-v2.zip
$ rm -rf colorfulflat-new-v2.zip
$ rm -rf __MACOSX/
$ mv colorfulflat-new-v3 html
 ※html配下をコンテンツデータとする。

Git初期化
$ git init
$ echo "#my campany site example" >> README.md
$ git add .
$ git commit -m "first commit"$ git remote add origin git@github.com:toguma/mycorpsite.git
$ git push origin master

```


#デプロイをCircleCiで自動化
---

ここまででようやくデプロイ準備が整ったので、
[CircleCi](https://circleci.com)にアクセスし、CircleCIアカウントを作成する。
(githubアカウント連動）

初回、Githubアカウントとのアクセス可否を求められるので、許可しておく。
その後はCircleCi管理画面からGithubリポジトリが見える状態となる。

![スクリーンショット 2015-11-24 18.51.32.png](https://qiita-image-store.s3.amazonaws.com/0/89940/85cebcdb-ad78-a67d-4a32-1fc5a61cc7cf.png)

　

[Add Project]から、該当リポジトリが表示されることを確認後、
[BuildProject]をクリックする。

![スクリーンショット 2015-11-24 18.51.44.png](https://qiita-image-store.s3.amazonaws.com/0/89940/dbf9b4f3-f220-bde4-e195-3cba1826f0ce.png)

　

BuildProject開始した後、自動でビルドが始まるが、
このタイミングではデプロイ制御ファイル(circle.yml)がない為、デプロイ失敗(Field)となるが正しい挙動なので、気にしない。
　

- AWSアクセスキーを設定

CircleCiにはデフォルトでAWSキーの設置箇所がある。
　
該当projectの[Project Setting]より
<img width="979" alt="スクリーンショット 2015-11-25 10.15.13.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/e8e1f748-9369-d469-64a7-0bd0431ba852.png">



[Parmissions]->[AWS Parmissions]
![スクリーンショット 2015-11-24 18.52.53.png](https://qiita-image-store.s3.amazonaws.com/0/89940/20f5992d-e42d-7a85-9f60-f8701f39fbe3.png)
　

IAMユーザ=s3-deploy-user作成時にダウンロードした[AccessKey][SeacretKey]を設置する。  

![スクリーンショット 2015-11-24 18.53.16.png](https://qiita-image-store.s3.amazonaws.com/0/89940/a98aab29-4fa3-8ef6-275f-fded398d6ebd.png)
 

　

- デプロイ制御ファイルの設置 

 GitリポジトリのTop階層に、
 circle.ymlというyaml形式のCirclrCI用のデプロイ内容を記述

```yaml:circle.yml
machine:
  timezone:
    Asia/Tokyo

dependencies:
    override:
        - sudo pip install awscli
    post:
        - aws configure set region ap-northeast-1

test:
  override:
    - echo "Nothing to do here"

deployment:
  production: # just a label; label names are completely up to you
    branch: master
    commands:
      - aws s3 sync html/ s3://s3site.proudit.jp/ --delete
  staging:
    branch: staging
    commands:
      - aws s3 sync html/ s3://st.s3site.proudit.jp/ --delete
```

内容を補足。
　リージョンはS3 bucket、IAMユーザ作成した場所と同じリージョンに指定。

1. Ci用マシンにAWS CLIをインストール
1. stagingブランチなら、ステージングサイトにデプロイ
1. masterブランチなら、公開サイトにデプロイ

という単純な動作を実現。
2,3のデプロイ先は適宜S3 bucket名と入れ替えのこと。
(またtest自体はダミーテストの為、実際にテストはしていない。
本当にコードテストを実施したい場合は適宜テストツールを導入して、コードチェックの自動化も可能。)


#git pushによるコンテンツデプロイ
---
以上で準備は完了。
まずはステージングサイトへコンテンツをアップ。

```bash:Githubへのpush例　CLI例(適宜ツール利用可）
staging用のブランチ作成
$ git checkout -b staging

適宜コンテンツ編集

$ git add .
$ git commit -m "staging site up"
$ git push origin staging
```

git pushに反応して、CircleCI側で自動でstagingブランチのビルド＝Deployが始まる。

Statusが[Success]or[Fixed]となれば、デプロイ成功。

<img width="673" alt="スクリーンショット 2015-11-25 10.42.52.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/33071631-3ea1-39f2-c2e3-b027ed0093c7.png">


S3 webhostingの閲覧用URLからアクセス可能なことを確認。
http://st.s3site.proudit.jp/

指定したアクセス制御がうまく行っていれば、
ステージングサイトはURLにて閲覧可能と成っているはずだ。
許可IP以外からのアクセスは拒否しているので下記「403 Forbiddn」が表示される。

<img width="411" alt="スクリーンショット 2015-11-25 10.58.02.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/f96a8796-bec9-a4d1-3697-ed607dfa12e9.png">




何度かステージングサイトへの修正,Pullrequestレビューを行って、公開に問題なしとなったら、masterブランチへマージ。
masterへマージされたタイミングで自動的に本番サイトへコンテンツアップされることを確認する。

http://s3site.proudit.jp/

<img width="1061" alt="スクリーンショット 2015-11-25 11.01.02.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/088bba80-c004-abc9-9458-9e55f1fee651.png">


#雑感
---
今回は
master = 本番サイト
staging = ステージングサイト
と定義してが、もちろんdevelopブランチ、develop用サイトを同手順で作成してもいいし、
releaseブランチで本番サイト公開、というデプロイルールとしてもいい。
この辺りは既存のGithub運用に合わせて調整すればいいと思う。


まだ、問い合わせフォームなどの動的ツールが未適用なので、
別途cognito＋lambdaを利用して実装すると、よりサーバレスな構成を実現できる。
が、それは後編で。


今日は一旦ここまで。

