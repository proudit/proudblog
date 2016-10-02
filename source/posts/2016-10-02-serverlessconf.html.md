---
title: ServerlessConf 2016 @Tokyo
date: 2016-10-02
tags: serverless
author: toguma
ogp:
  og:
    description: 'serverlessconf 2016@tokyoに参加してきました。'
---

2016/9/30 - 10/1にて開催された「ServerlessConf 2016@tokyo」に参加してきました。

<img width="1277" alt="serverlessconf.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/7d10b401-e5b9-7afc-a696-c85ec4aa9d1c.png">


[serverlessconf@tokyo 公式ページ](http://tokyo.serverlessconf.io/)

<br>

今回は運良く、前日のワークショップ参加チケットをGetできた(先着50名？くらい）ので、9/30夕方からのワークショップの様子からの報告です。
<br>

#ServerlessConf Tokyo 9/30 - Zombie Workshop 
---
by Nishitani - AWS

![0-0.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/2080edd1-b307-c603-6240-52782e1774ce.jpeg)

このワークショップは去年のre:inventで人気だった様で、今では正解各地でリバイバルされているとのこと。

しかも開催現地の状況(言語など）に合わせてカスタマイズされている模様。

以下は海外開催時の元ネタスライドだが、実際は日本語版で説明された。
<br>

[説明スライド](http://www.slideshare.net/AmazonWebServices/zombie-apocalypse-workshop-by-warren-santer-and-kyle-somers-solutions-architects-aws)

<br>

概要は、

***世界中にゾンビが現れ、各首都が壊滅状態。
生き残った人通しが互いに連絡取るためのリアルタイムチャットシステムをサーバレスで作成しなくてはならなくなった。***

という設定。中二的で面白いw

非公開ワークショップなので実際のコード、詳細画面は公開できないが、雰囲気は以下の感じ。


![0-1.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/b4c07ee7-e005-e867-6241-fe3451188e5c.jpeg)

AWS西谷さんからの概要、進め方の説明。
<br>

![0-2.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/e8574d08-7523-1a26-c623-32a7cf2dc419.jpeg)


![0-3.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/15efa1a5-2495-8f54-7325-e552e49735f1.jpeg)

その後は黙々とLabに取り掛かる。

<br>
![0-4.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/523034ba-4f26-b175-3f87-defec4c25359.jpeg)

![0-5.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/22a375f5-65b1-fd1a-1543-dae591841223.jpeg)

途中、食料が配給されましたw

<br>
<img width="1260" alt="0-7.png" src="https://qiita-image-store.s3.amazonaws.com/0/89940/859880b8-befe-e47f-8606-2d300be38a84.png">

結果的にはこんな感じのチャットシステムを、S3/Lambda/Cognite UserPool/API Gateway/ElasticSerach/twllio/Slack　を駆使して組み上げました。


PM17:00から30分ほどの説明、準備の後、21:30までの約4時間、ガッツリ張り付いてやって終わるかどうかのボリューム。

自分はなんとかギリギリ最後のLab4まで終わらせることができた。

完遂した人は3、4割ってところでした。

疲れましたが、サーバレス構成がよく理解でき、達成感のある充実したワークショップでした。

<br>
さあ、この盛り上がった気持ちのまま、翌日の本番カンファレンスへ。

<br>


#ServerlessConf @Tokyo 10/1
---


会場のTABLOID

![tabloid.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/47e3f496-6efb-c058-77ff-ed2e9fb50d69.jpeg)

![kanban.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/8e3415b3-5a9c-6ba4-c8e3-9c25a87b2591.jpeg)

会場は縦長で、2F観覧席もある、オシャレな感じでした。

いつもはライブとかで使うのかな？

![2f1.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/806befc3-d706-1f14-f6cc-96c232a78a64.jpeg)

![2f2.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/905f038d-5ec2-ab26-8e5b-70f046277864.jpeg)

<br>

#1 Intro
---
by Shingo Yoshida - Section-9


主催者様のご挨拶。

さあ、serverlessconf 2016@tokyoの始まりです！

![intro.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/2fbfe932-3ac0-c4bd-7ae1-0457fb99aab1.jpeg)

<br>

#2 Keynote: Go Serverless, Compute Only When it Matters!
---
by Olivier Klein - Amazon Web Services

（資料公開され次第更新予定）

![2-1.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/01a832dd-c028-4530-f1db-9f9ffae0df7f.jpeg)


Serverless with AWSの解説。
facebookイベント連動デモ
Alexa との連動デモ
など、さすがAWSアーキテクターのデモだけ合って、魅せるデモだった。

![2-2.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/497e59f9-b5a4-c99a-70d3-23b6dc299a87.jpeg)


特にAlexaは感動。

<br>

#3 SERVERLESS WITH NATIVE APPLICATION FOR NEWSPASS
---
by Yuki Matsumoto - Gunosy

[発表資料はこちら](https://speakerdeck.com/ymatsuwitter/serverless-with-a-native-application-for-newspass)

<br>

![3.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/5cce72b1-2d0c-0df9-ff8a-12e7db822cde.jpeg)


よくある運用からの視点ではなく、モバイル開発者視点から見たサーバレスアーキテクチャの実装話。

モバイルクライアントリソースを有効利用＋サーバレスで効率化する。

個人的には本筋ではないところで、40名参加のハッカソンの評価システム=ベンチマーカーをLambdaで実装して、2日間ぶん回したのに、利用額**$3**だった、という話が気になった。

（後のパネルディスカッションで少し触れてくれた）

<br>

#4 EVENT-DRIVEN AND SERVERLESS COMPUTING WITH OPENWHISK
---

by Dr. Andreas Nauerz - IBM

[発表資料はこちら](http://www.slideshare.net/OpenWhisk/ibm-bluemix-openwhisk-seminar-at-ibm-tokyo)

![4.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/dc80c0ec-7568-3b0c-8cfd-a977ef11a5f3.jpeg)


IBM のイベント駆動型マイクロサービス・アーキテクチャ

Bluemix Whisk の概要説明＆デモ

<br>

#5 Lunchtime Speakers Session !!
---

お弁当、お茶が用意されておりました。

ランチセッションなのに、皆食べながらしっかり聴講しているのが印象的でした。

もちろん私も。


<br>

#Unlimited Frameworks
---
by MASASHI TERUI - Willyworks, Serverworks, Section-9

[発表資料はこちら](http://www.slideshare.net/marcyterui/unlimited-frameworks)

![l-1.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/0272fd41-e710-dbb6-276b-214f16db1934.jpeg)


Lambda/APIGateway用のLamberyというフレームワークの作者でもあるスピーカー自ら、
各メジャーツールの現状とその比較。
どこも一長一短な感じはあるが、serverless freamworkが一日の長か？
いやいや、もちろんLamberyも良さそうでした。（今日知ったので、使ったことないですが、、）

<br>

#Firebaseを使ったサーバーレスWebアプリケーション開発
---
by KIHARU SASAKI - Section-9

[発表資料はこちら](https://speakerdeck.com/kiharu/serverless)

![l-2.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/47540652-95c6-6ea4-8da0-102296e0a956.jpeg)


ストレージGCP Storage / FaaS GCP Function(bate) /メール Sendgrid との連携を駆使することでかなりの機能をサーバレスで実現可能。

<br>

#6 サーバレスとマイクロサービス変わるゲームサーバ開発
---
by Kazutomo Niwa - GS2

[発表資料はこちら](https://speakerdeck.com/kazutomo/saharesutomaikurosahisutebian-warukemusahakai-fa)

![6.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/be3c4c89-7e51-1e35-061b-c91f95c33e9f.jpeg)


サーバレスアーキテクチャ＋マイクロサービス化で実現したゲームサーバ用サービス事例

- スケーラビリティ
- 可用性
- 保守性
- 価格優位性

lambda Java起動は遅い。その後は早い。

使い分けが大事。

API受付 Python/javascript  バッチはJava

とても共感できたところ。

仮想化の流れはコンテナを通り越してサーバレスか、という感覚。

コンテナ開発・運用は言うほど楽ではないし、、

ならEC2 + FaaS(Lambda)構成の方が楽？という感覚。。

とはいえ、適材適所が大事そう。

<br>

#7 OPERABILITY IN SERVERLESS ENVIRONMENTS
---
by AllanEspinosa - Engine Yard

（資料公開され次第更新予定）

写真撮り忘れた。。

日本独特の文化？根回し・ホレンソが大事！

あ、いやもっと良いこともたくさん言ってましたが、上のワードの印象が強烈で、、


<br>

#8 Serverless Patterns with Azure Functions
---
by Naoki Sato & Tsuyoshi Ushio - Microsoft

[発表資料はこちら](https://satonaoki.wordpress.com/2016/10/01/serverlessconf-tokyo/)

![8.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/d7c4234b-651d-ecba-24c0-46ac936d4976.jpeg)


冒頭から熱いセッションだった。

AWS利用者優勢の圧倒的なアウェイ感からか、
**Azure Server=EC2っぽいやつ、Azure Function=Lambdaっぽいやつ、
Azure Storage=S3っぽいやつ**、と半ばヤケに自虐ってたのが印象的w。

Azure Functionデモ

料金体系　スタティックタイプと、ダイナミックがある。ダイナミックの方がいわゆるサーバレス。

ゲームデモ unityで作成　写真から感情解析して反応。

[ゲームデモ資料](http://qiita.com/kosfuji/items/575408ae17113d7b58e9#comment-c2191860e90a5f50d111)

<br>

#9 IoT/GPSトラッキングプラットフォームがサーバレスだからこそ2ヶ月で構築できた話
---
by YUUKI TAKAHASHI - StyleZ Corporation

[発表資料はこちら](http://www.slideshare.net/ukitiyan/iotgps-2)

![9.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/b7261b35-a2fe-8a8f-6c8a-6575046f1ff2.jpeg)


tracker.ioサービスをサーバレスで実装した話。

スモールスタートを実践。

自律した開発が可能。疎結合がゆえに、機能追加がしやすい。

などのメリットの反面、

コードベースがバラバラ(java/node/python)の為、デプロイ自動化の工夫が必要、

総合的なログ収集・検知する仕掛けが必須、ラーニングコストはそれなりに高い、

を上げていた。どれも納得。

<br>

#10 Disrupting old business models: the story of a serverless startup
---
by Sam Kroonenburg & Peter Sbarski - A Cloud Guru

![10.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/558c473b-4cd0-57b0-051b-7137c14e2abc.jpeg)


伝わったメッセージ。

- コンピュートLmabda ストレージS3、ステートレスに。
- シングルタスクFunctionに
- プッシュ・イベントドリブンベースのデータパイプラインに。
- フロントエンドアプリをパワフルに
- third party servicesを使おう

さすが本場やー説得力あるわー。な話でした。

<br>

#11 紙面ビューアーを支えるサーバーレスアーキテクチャ
---
by Taishi Ikai - Nikkei Inc.

[発表資料はこちら](https://speakerdeck.com/ikait/serverless-architecture-supports-nikkeis-paper-viewer)

![11.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/a61dcb56-1666-d7bb-6653-df43e5944b83.jpeg)


日本事例では一番現場開発の臨場感が伝わるセッションでした。

紙面記事バッチ処理。

従来方式　EC2 ポーリング問題・スケールアウト時間が問題をサーバレス(lambdaで）にした話。

Max2万件/Dayレベルで動いているのに、1年ほどlambda起因のエラーは起こってない、
という実績はやっぱ凄い。

当たり前だが、運用コストがほぼないとのこと。

とはいえ、Lambda実装はそれなりにラーニングコスト・開発コストはあるよ、というのも納得。

<br>

#12  Building Serverless Machine Learning Models in the Cloud
---
by Alex Casalboni - Cloud Academy

[発表資料はこちら](http://www.slideshare.net/AlexCasalboni/building-serverless-machine-learning-models-in-the-cloud)

![12.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/3b1ebf61-e7cf-8589-fb4c-6a90063279f4.jpeg)


データ収集をサーバレス、学習はEC2(Spot)で実装。

使い分けに無駄のないMLモデル、、に感じた。（ML自体はよくわかってないが。。）

さすがにLambdaでMLモデルトレーニングするには最大5分の実行時間じゃ足らない。
というのはわかる気がする。

Lambdaは重いバッチ？というか解析には向いてない。

本場の方々はそのクラウドリソースの使い分けがしっかりしていることを感じた。


<br>

#Lightning Talks !!
---

<br>

#MQTT を利用した github pages でホストできる REST Like な API サーバホスティング
by Daichi Morifuji - NIFTY

[発表資料はこちら](https://speakerdeck.com/muddydixon/using-mqtt-we-can-make-our-apps-serverless-but-dot-dot-dot)

![lt-1.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/3b47a903-0ea3-2d46-9036-827d4a157391.jpeg)

<br>

#WordPress shift Serverless. ~ ServerlessアーキテクチャはWordPressの何を解決したのか ~
---
by Takahiro Horike - DigitalCube

Wordpressのデメリット

- updateが早い。
- traffic問題
- Attack問題

じゃあ、サーバレスにすればいいという発想が、Shifter。

Wordpressを必要な時に立ち上げるだけコンテナで起動。

記事ポスト後、Lambdaで静的ファイルを生成、S3/CF配置。

なるほど。と思った。

今はクローズドベータ版とのこと。でもURL登録すれば皆使えるって。
ん？クローズド？ま、まあいいか。

<br>

#Realmで実現するサーバーレスアプリケーション
---
by Kishikawa Katsumi - Realm

[発表資料はこちら](https://speakerdeck.com/kishikawakatsumi/realmdeshi-xian-suru-sabaresuapurikesiyon)

Realm Mobile Database SQLite代替えのモバイルデバイス専用のデータベース

Realm Mobile Platform DataSync/UserIdentify/AccessControl/EventHandring

<br>

#パネルディスカッション
---
by Naoya Ito

[アジェンダ](https://github.com/naoya/serverless-conf-agenda/blob/master/agenda.md)

![panal.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/a5c17852-f96a-0199-e372-838fa67a200a.jpeg)


サーバレスの定義

２つの視点、OSとしてのサーバレスか、プロセスとしてのサーバレスか？

今日の文脈では後者の定義が当てはまりそう。


パネラー含めた皆さんが、

サーバレス=FaaS=Lambda、という前提は誰も否定しないところが妙に現状を表していた。


サーバレス/モノシリック構成の境目はどこ？サーバレスの未来は？など
司会伊藤さんの絶妙なトーク回しでパネラーの皆様、サーバレス談義は盛り上がった。
<br>

印象に残ったのは会場からの質問

***Q こんなに日本もサーバレス熱が高いのに「日本のサーバレスは海外のそれよりも1年半くらい遅れている」といわれるのはなぜ？***

A 慎吾さん。

海外では今日のディスカッションのような話はすでに1年半前に議論された上で、現在は適材適所で積極的にサーバレスへシフトし、かつちゃんとビジネスとして利益を出している事例が圧倒的に多い。

納得である。日本はまだアーリーアダプターの中でもまだ一部の成功事例しかお目にかかってない気がする。

<br>

#Serverless Social !!
---

ということで、AM10:00から始まって、気がつけばPM19:00過ぎまで盛り上がったサーバレスセッション。
その余韻のままにビール片手に乾杯へと流れた。

![party1.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/fff54d82-22af-d388-4fb5-1d8216f6d6ae.jpeg)

![party2.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/c7e9eebc-a017-1bd9-647d-6360331ab12a.jpeg)

![party3.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/45375d78-6a1d-ae4c-c30a-21e8537600ff.jpeg)



ご飯、ちょーおいしかったです。

<br>

#まとめ
---
2日間のserverlessconf。非常に良かったです。

これからのサーバレスの波を確かに感じました。

一番の収穫は

***「サーバレスは銀の弾丸ではない！」***

と一様にスピーカー、パネラーの方がおっしゃってたこと。

確かにサーバレスが全てを解決するわけでも、楽にするわけでもない。

様々な他のクラウドネイティブアーキテークチャーをよく理解した上で、適材適所で使い分けられるようになること、が大事だと感じました。


ちなみに今回得た戦利品。

![IMG_1567.jpg](https://qiita-image-store.s3.amazonaws.com/0/89940/bba5cd2c-ed33-1b59-6a6f-d45d57ced919.jpeg)


以上です。








