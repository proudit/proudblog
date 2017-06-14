---
title: AWS Summit Tokyo 2017 メモ -「全部教えます！サーバレスアプリのアンチパターンとチューニング」
date: 2017-06-14
tags: AWS
author: kohei
ogp:
  og: '先日行われた AWS Summit Tokyo 2017 の「全部教えます！サーバレスアプリのアンチパターンとチューニング」メモです'
---


# はじめに
先日行われた **AWS Summit Tokyo 2017** の「[全部教えます！サーバレスアプリのアンチパターンとチューニング](http://www.awssummit.tokyo/devday/index.html#D4T7-2)」メモです。

「**AWS Lmbdaを中心としたサーバレスアプリケーションで発生しがちな問題とその対応策について**」のセッションでした。


<br>
# Lambdaが遅い理由
考えられるポイント

- プログラム
- コンピューティングリソース
- アーキテクチャ

**プログラム** → 各言語のベストプラクティスに従う
**コンピューティングリソース** → メモリ設定を行うメモリサイズと比例して割り当てられるCPUリソースも割り当てられる。つまり、メモリを倍にするとCPUも倍。


<br>
# Lambda設定の最適値設定方法
メモリを増やした際に処理時間が大きく短くなる場合がある。
その場合は処理時間が短くならなくなったところが最適値と考えてOK。


<br>
# Lambdaファンクション実行時に起きていること。

1. (ENIの作成)
2. コンテナの作成
3. デプロイパッケージのロード
4. デプロイパッケージの展開
5. ランタイム起動・初期化
6. 関数/メソッドの実行

1〜6を実行するのが**コールドスタート**。
1〜5は基本的に毎回同じ内容が実行される → 再利用することで省略して効率化(**ウォームスタート**)。


<br>
# コールドスタートが起こる条件
利用可能なコンテナがない場合に発生

- 1つもコンテナがない状態
- 利用可能な数以上に同時に処理すべきリクエストが来た
- コード、設定を変更した
安定的にリクエストが来てたらコードや設定を変更しない限りコールドスタートはほとんど発生しない


<br>
# コールドスタートは回避できるの？
コールドスタートは利用者側でどうにかできる領域ではない。なので基本的に回避はできない。
つまり、コールドスタートを０にすることは難しいため、それが許容できないのであればAWS Lambdaは使うべきでない。


<br>
# 実行を早くするには？
- *コンピューティングリソースを増やす
→コンピューティングリソースの割り当てを増やすことで初期化処理が早くなる

- *ランタイムを変える
→AWS Lambdaに限らずJVMの起動は遅い、ただし、一度温まるとコンパイル言語の方が速い傾向。

- パッケージサイズを小さくする
→サイズが大きくなるとコードのロード及びZip展開に時間がかかる(不要なコードは減らす, 依存関係を減らす, 不要なモジュールは含めない(特にJava))
　→JavaだとProGuardなどのコード最適化ツールを使って減らすという方法もある。

- *VPCは必要でない限り使用しない。
→使うのはVPC内のリソースにどうしてもアクセスする必要があるときだけ。
→VPCを有効にしているとコールドスタート時に10秒から30秒程度余計に必要になる。
→同期実行が必要な箇所やコールドスタートを許容できない箇所ではなるべく使わない。
→VPC内のリソースとの通信が必要なのであれば非同期にする。

- 初期化処理をハンドラの外に書くとコールドスタートが遅くなる。


<br>
# アーキテクチャの問題
- 同期でInvokeすると同時実行数の制限に引っかかって詰まりがち。
- できるだけ非同期でInvokeするのがスケーラビリティの観点ではオススメ。
- Think Parallel:並列処理を行う。
- 1つあたりのイベントを小さくして同時に並列で動かせるようなアーキテクチャにする。


<br>
# 同時実行数
- 関数の平均実行時間：3s/exec
- 同時実行数="同時"に実行されているタイミング
- 秒間リクエスト：10req/sec
- ストリームベースの場合はシャード単位


<br>
# Limit Increase（上限緩和）について
標準では1000、実績がない状態でいきなり数千とか数万を申請しても通らない。
もし実績がない状態でどうしても緩和したい場合はサポートへ直接相談。


<br>
# 気をつけよう
- Lambda + RDBMS → Amazon DynamoDBを使う方が良いのでは？
- IP固定したがり問題 → 署名や証明書などで担保すべき。
- サーバレスであれば全く運用が必要ない、インフラ費用が10分の1になる → サーバの管理は不要だが運用は必要。
- Serverless != Monitorless


<br>
# Lambda使う際の注意
ちゃんとエラー検知などは入れましょう。

- CloudWathcのメトリクス、Errors,Throttles
- CloudWatchのカスタムメトリクス


<br>
# おわりに
セッションの講演資料がちゃんと共有されているので詳しく知りたい方はそちらを参照願います。

- [**全部教えます！サーバレスアプリのアンチパターンとチューニング**](https://speakerdeck.com/keisuke69/quan-bu-jiao-emasu-saharesuahurifalseantihatantotiyuninku)（Spearker Deck）


<br>
# 関連書籍
「[実践AWS Lambda](http://amzn.to/2skImhg)」はセッション登壇者の西谷さんが書かれた本です。

<a href="https://www.amazon.co.jp/%E5%AE%9F%E8%B7%B5AWS-Lambda-%E3%82%B5%E3%83%BC%E3%83%90%E3%83%AC%E3%82%B9-%E3%82%92%E5%AE%9F%E7%8F%BE%E3%81%99%E3%82%8B%E6%96%B0%E3%81%97%E3%81%84%E3%82%A2%E3%83%97%E3%83%AA%E3%82%B1%E3%83%BC%E3%82%B7%E3%83%A7%E3%83%B3%E3%81%AE%E3%83%97%E3%83%A9%E3%83%83%E3%83%88%E3%83%95%E3%82%A9%E3%83%BC%E3%83%A0-%E8%A5%BF%E8%B0%B7-%E5%9C%AD%E4%BB%8B/dp/4839959110/ref=as_li_ss_il?_encoding=UTF8&psc=1&refRID=RVB9CJ2YJXRD77SMDGMP&linkCode=li2&tag=books-mania-22&linkId=f3c5bf8025dc6738c63fd316033645ad" target="_blank"><img border="0" src="//ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=4839959110&Format=_SL160_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=books-mania-22" ></a><img src="https://ir-jp.amazon-adsystem.com/e/ir?t=books-mania-22&l=li2&o=9&a=4839959110" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />　<a href="https://www.amazon.co.jp/gp/product/4873118069/ref=as_li_ss_il?ie=UTF8&pd_rd_i=4873118069&pd_rd_r=TTZ2B8JEVHNPG1E6SKS1&pd_rd_w=WTGIM&pd_rd_wg=iWuA0&pf_rd_m=AN1VRQENFRJN5&pf_rd_s=&pf_rd_r=BB9YEFDJ91G91QQBF8J9&pf_rd_t=36701&pf_rd_p=345051a4-16fd-490b-9c34-36fcc2c13ed1&pf_rd_i=desktop&linkCode=li2&tag=burger03-22&linkId=789380ded9d90cf725bbbb3b6e48589d" target="_blank"><img border="0" src="//ws-fe.amazon-adsystem.com/widgets/q?_encoding=UTF8&ASIN=4873118069&Format=_SL160_&ID=AsinImage&MarketPlace=JP&ServiceVersion=20070822&WS=1&tag=burger03-22" ></a><img src="https://ir-jp.amazon-adsystem.com/e/ir?t=burger03-22&l=li2&o=9&a=4873118069" width="1" height="1" border="0" alt="" style="border:none !important; margin:0px !important;" />

