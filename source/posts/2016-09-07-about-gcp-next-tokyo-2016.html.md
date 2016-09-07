---
title: GCP NEXT Tokyo 2016に行ってきました！
date: 2016-09-07
tags: GCP
author: kohei
ogp:
  og: '昨日(2016年9月6日)、芝公園にあるザ・プリンスタワー東京で**GCP NEXT | World Tour | Tokyo 2016**が開催されたので行ってきました。'
---

![GPCNEXT](./2016/0907_about_GCP_NEXT_Tokyo_2016/gcp_next_tokyo_2016.jpg)
昨日(2016年9月6日)、芝公園にあるザ・プリンスタワー東京で**GCP NEXT | World Tour | Tokyo 2016**が開催されたので行ってきました。

<br>
# GCP NEXTとは？
Google Cloud Platformに関する最新クラウドテクノロジーについての発表や活用事例を発表するイベントです。
その他にGCP導入企業との交流やハンズオントレーニングも行えます。

<br>
# どんな企業が参加しているの？
![GoogleApps](./2016/0907_about_GCP_NEXT_Tokyo_2016/GoogleApps.jpg)
GCPでシステム構築・運用などを行うMSPの企業やGCPをベースに構築したサービスを提供する企業、CDNなどのGCPと組み合わせて利用できるサービスなどを展開する企業など様々でした。

今回ブース出展していた協賛パートナーは以下です。(※アルファベット順)

- [accenture](https://www.accenture.com/jp-ja/)
コンサルティング会社です。

- [BrainPad](http://www.brainpad.co.jp)
ビッグデータを活用した解析や機械学習、AIなどに力を入れている会社です。

- [Cloud Ace](https://www.cloud-ace.jp)
Google Cloud Platformの導入・運用をワンストップでサポートするMSPサービスです。

- [Cross](http://cross-rendering.jp)
Googleのクラウドコンピューティングでレンダーファームサービスを提供している会社です。

- [EQUINIX](http://www.equinix.co.jp/locations/japan-colocation/tokyo-data-centers/?ls=Advertising%20-%20Web&lsd=16q2_enterprise_people__google_cpc_jp-jp&utm_campaign=people&utm_medium=cpc&utm_source=google&utm_term=equinix&gclid=CNmSxpHE_M4CFQpwvAodAesP0g)
データセンター事業を展開する会社です。ビットアイルを買収したことでも有名ですね。

- [fastly](https://www.fastly.com)
CDNサービスを提供する会社です。

- [grasys](http://www.grasys.io)
システム設計・構築・運用保守を行うMSPの会社です。

- [Groovenauts](http://www.groovenauts.jp)
画面上のブロックを配置して複雑なクラウド機能をつなぎあわせる「BLOCKS」というサービスを提供している会社です。

- [intel](http://www.inter.it/jp/hp)
CoreプロセッサなどのCPUを製造している半導体メーカーです。

- [ISAO](https://www.isao.co.jp)
クラウドマネージメントの「くらまね」をサービスとして提供している会社です。

- [JIG-SAW](https://www.jig-saw.com)
システム設計・構築・運用保守を行うMSPの会社です。

- [JSOL](https://www.jsol.co.jp)
ITコンサルティング会社です。

- [mackerel](https://mackerel.io)
モニタリングプラットフォームを提供する会社です。

- [TECHORUS](https://nhn-techorus.com)
ITインフラを提案・構築・運用支援などを行う会社です。

- [TOKAIコミュニケーション](http://www.tokai-com.co.jp)
ネットワーク・データセンター・システム開発を三位一体で展開する会社です。

- [TOP GATE](https://www.topgate.co.jp)
Googleの技術をコアとした開発やコンサルティングを行う、Google技術者集団です。

![GDC](./2016/0907_about_GCP_NEXT_Tokyo_2016/gdc.jpg)
![GCP](./2016/0907_about_GCP_NEXT_Tokyo_2016/gcp.jpg)

<br>
# どんな内容が聞けるの？
午前中は基調講演です。お昼を挟んで午後からは「事例紹介」や「各種サービスの技術」についてA・B・Cの３会場に分かれて講演が行われました。
[アジェンダ](https://cloudplatformonline.com/NEXT2016-Tokyo-Agenda.html)
どのセッションもほぼ満席みたいでしたが、特にゲーム系のセッションが開場前から行列だったので人気があったのかなと感じました。
![schedule](./2016/0907_about_GCP_NEXT_Tokyo_2016/gcp-schedule.png)

<br>
# 今回気になったサービス
## ●STACKDRIVER
なんと言っても[**Stackdriver**](http://www.stackdriver.com)ですね。
マルチクラウド管理に対応したモニタリングツールで、「**モニタリング、ロギング、デバッグ、トレース、エラーレポーティング**」と言ったことが行えます。
しかもAWSにも対応(というかテクノロジーパートナーですw)しているので両方のパブリッククラウドを利用している企業などは一元管理できるのでとても便利なのではないかなと思います。
現在、β版で無料で利用できるので今のうちにもっと試して使い勝手などを検証したいと思います。
![stackdriver](./2016/0907_about_GCP_NEXT_Tokyo_2016/stackdriver.png)

<br>
## ●GAE
個人的に[**GAE(Google App Engine)**](https://cloud.google.com/appengine/?hl=ja&utm_source=google&utm_medium=cpc&utm_campaign=2015-q1-cloud-japac-jp-gae-bkws-freetrial-jap&utm_term=gae&gclid=CKGltMq8_M4CFYWUvQodkFcI4A)も良いです。
でもGAEは昔からある成熟したサービスだと言われました。。。勉強不足。。。
とはいえ、せっかくなのでGAEについて!

[GAE](https://cloud.google.com/appengine/docs/whatisgoogleappengine?hl=ja)とはGoogleのインフラの上でアプリケーションを作り、実行できるようにする「**Paas**」です。利用者はただ、アプリケーションをGAEへアップロードするだけで実行できます。ランタイム環境としては現在「Java、Python、PHP、Go」をサポートしているみたいです。
無料枠もあるみたいで**1日28時間までサポート**されています。つまり１台動かす分には無料ということです。
しかも**使った分だけ課金**になるので、アップロードしてもアクセスがない場合は課金されません。良いですね！
逆に負荷が高くなった場合、自動でオートスケーリングしてくれます。ここで気になったのが、上限値は設定できるんですかね？できるはずですよね？そこ重要ですよね！？要チェックや。。。
また、聴講していて他にいいなと思ったポイントはバージョン管理機能みたいなのがあるらしく、
アップロードした内容がOKであれば管理画面上で切り替えることができるんだそうです。いわゆる**blue/greenデプロイみたいなことが可能**との事です。
昔からあるサービスなだけあって、GAEは「ザ・GCP」と言った感じですね。
![GAE](http://23.251.145.25/wordpress/wp-content/uploads/2014/03/gae_image.jpg)

<br>
# おわりに
パブリッククラウドと言ったらAWSというのはまだまだ拭えないですが、東京リージョンもついにやってくるとの事で、ここからのGoogleの追い上げに注目です。

