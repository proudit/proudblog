---
title: JAWS-UG コンテナ支部#6　参加レビュー
date: 2016-09-25
tags: AWS,jaws,ecs
author: toguma
ogp:
  og: '9/21(水)に行われたJAWS-UGコンテナ支部の参加した後に感じたこと、思ったことを並べてみた。'
---

##JAWS-UG コンテナ支部 #6　参加レビュー
9/21(水)に行われたJAWS-UGコンテナ支部の参加した後に感じたこと、思ったことをまとめてみた。

![JAWS-UG コンテナ支部](/images/jaws-container-logo.png)


<br>

#ALB/ECSサービス
---
AWSJ 辻さん/岩永さんより、先日発表されたALBサービス説明ならびにECSのアップデート情報の説明があった。この中でやはり注目はALB+ECSのDynamicPortのサポート。

DynamicPortのサポートはECS利用のユーザにとって待ちに待ったサービス。私も、今まで足りなかったピースがハマった感があり、登壇者も参加者も一様に興奮していたように感じられた。

<br>

#ALB DynamicPortサポートとは
---
ELB+ECSは自動連携は可能だったが、ELBから見ると通常のEC2ホスト配置同様で、ホスト側は固定ポート指定しか出来ない。
よって例えばWeb系コンテナをELB配下に分散配置する場合は最低でも2ホストが必要であった。

ALBによるECS(Docker)DynamicPort対応により、ALBからはホストではなく、別ポートを持ったコンテナが直接配置されるようになり、今までのELB+ECSにあった固定ポート/ホスト数制限から解放された。

<br>


#DynamicPortサポートで何が嬉しい？
---
いろんな意見はあると思うが、個人的には「Blue/Greenデプロイ構成」が気軽に実装できること。だと思う。

Blue/Greenデプロイは新旧コンテナを同時に起動させ、LB上で降り先を切り替えることによるオンラインデプロイ方式。

ELB利用時のBlue/Green実装例を見ると

- webコンテナは常に空いているECSホストで起動＝**余裕を持ったホスト稼働が必要**
- ECSホスト単位でBlue/Greenを実装し、AutoScale or DNSレベルで切り替え＝**準備・構築が複雑。**
- HAproxyなどで自前でDynamicPortへ対応させる＝**ミドル構築めんどくさい。。**

<br>
などが必要で正直、リソース・工数効率の面から気軽に採用出来なかった。

これがDynamicPort対応により、ホスト数に縛られないより柔軟なコンテナ配置が可能となり、Blue/Greenデプロイが構成しやすくなったと思う。。

<br>

#構成例
---
例えば、最小ECSホスト1台でも構成可能なので、AWSの1年間無料枠(EC2-t2micro+ALB+ECS)で、Blue/Green環境が構築出来てしまう。（この無料枠構築は別途記事掲載予定）

<br>
<br>

#Github + CircleCI + 〇〇によるデプロイ事例
---
登壇者の様々なDockerコンテナ利用状況、デプロイ方式についても非常に参考になった。
全体を通じてみると、Github + CircleCIによるオートデプロイ構成は結構な割合で採用されているように見受けられた。

- [『Quipper におけるコンテナ今昔物語 - PaaS (Deis/Heroku) を中心に据えた DevOps』](https://speakerdeck.com/hakobera/quipper-on-containers) @hakobera さん 
- 『ECS/CodeDeploy デモ』 @pottava さん 

<br>

などの構成例でもGithub - CircleCIを利用されていた。
<br>

Dockerを利用したアプリ開発者にとってはサーバ構築が必要ない、Github + CircleCIはかなり相性がいい模様。(Jenkins職人不足？w）

<br>

@pottavaさんのデモ自体は想定外の端末ハプニング？もあり、うまく行きませんでしたが、
ECS/ElasticBeanstalk/EC2(docker)へのそれぞれのパターンのGithub + CircleCI + CodeDeployによるデプロイ構成はとても参考になった。

<br>


ちなみにウチの自社サービスは以下のようなGithub-CircleCIでデプロイ中。

Githubへのpush -> CircleCIでテスト・dockerビルド・ecs-deploy　-> ECSでの自動ローリングデプロイ

![proudcloud-deploy](/images/proudcloud-deploy.png)

<br>
<br>

# ECSデプロイにまつわるエトセトラ
---

- [ECSのデプロイツールを試している話](https://speakerdeck.com/yukiyan/ecsfalsedepuroituruwoshi-siteiruhua)　ゆきやん さん 
<br>
<br>
様々なECSデプロイツールを検証した内容はとても参考になった。

特にecs-cli up の簡単さには少々驚いた。あれだけ簡単だと、Blue/Green前に必要数のECSを起動、が簡単に書けそうだ。

新プロジェクト環境でECS構築する際のCLIコードが今より格段に減りそう。

ecs-deployは弊社でもCircleCIからのデプロイ連携で利用中。この部分、用途では特に不具合もないのでecs-deployを使い続けると思う。

ecs-formation/hako など今まで扱ったことのないデプロイツールも一長一短がありそうなので、今後はウォッチして行きたい。
<br>
<br>

#デプロイに時間がかかる、問題
---

- [Dockerホットデプロイ運用の話](https://speakerdeck.com/glidenote/operations-for-zero-downtime-docker-deployment)　glidenote　さん
<br>
<br>

LT発表の中で、この@glidenoteさんのデプロイが遅い問題が、自分がとても共感している内容だったこともあり、非常に参考になった。

ALB + ECSのBlue/Greenデプロイ時、Deployment Optionsの設定によってはとてもデプロイに時間が掛かる。

ちなみに、ECSのデプロイはECSの「Deployment Options」設定にある、下記に準じて行われる。
<br>
Development Options設定

```
Minimum healthy percent ＝ デプロイ時に許容する最小コンテナ数

Maximum percent = デプロイ時に許容する最大コンテナ数
```


<br>


##遅いデプロイ

例えば、ALB + 2コンテナ構成で、 Min=50% / Max=100%　稼働しているサービスの場合
<br>

1. デプロイ開始
2. 既存2コンテナの1つを停止(事前にALBから外す）
 - 50%でサービスしている状態(healty percent 50%)
3. 新コンテナ(新Taskリビジョン)を1つ起動(ALBが新コンテナを登録)
 - バージョン違いのコンテナが起動する最大数(Maximum 100%)
4. 残った既存1コンテナを停止(事前にALBから外す）
5. 新コンテナ(新Taskリビジョン)を1つ起動(ALBが新コンテナを登録)
6. デプロイ完了

<br>
この一連のECSのデプロイ処理完了まで時間が掛かる(状況にもよるが概ね15分〜20分）

2〜4の停止処理の発動に時間が掛かっているように見受けられる。

ALB側のhelthcheck間隔、セッション保持時間など諸要件は関連するだと思う

→**これが、いわゆる「デプロイ遅い」問題**

<br>
<br>

##比較的早いデプロイ
ALB + 2コンテナ構成で、 Min=100% / Max=200%　

上記のように倍にすると、上記に比べてデプロイが早い。(状況にもよるが3分〜5分)
<br>

1. デプロイ開始
2. 既存コンテナはそのままで新コンテナ(新Taskリビジョン)を2つ起動(ALBが新コンテナを登録)
 - サービスは100%稼働のまま(healty percent 100%)
 - バージョン違いのコンテナが起動する最大数(Maximum 200%)
3. 既存2コンテナを停止(事前にALBから外す）
4. デプロイ完了

<br>
デプロイ時もサービスコンテナ数が減らないのでサービス安定性は向上

ただし、Max=200%の為、デプロイの為に常に倍のリソースを確保しなければならないということ。

→**これはリソース効率が悪い**

<br>

もちろん、安定要件、費用要件によって選択すればいいだけの話だが、可能なら

- リソース効率は良くしたい
- デプロイ時間は早くしたい

<br>
を実現したい。

glidenote　さんは、デプロイ実行前に自動で、Max200%に耐えれるだけのECSホストを追加させる方式で対応していた。

なるほど。ECS起動時間分は掛かりますが、それでもトータルで見るとデプロイは早くなりそう。

とはいえ、、１日に何回もデプロイすると、その分追加ECS分の費用がかかるのでこの辺はSpotインスタンスを併用したりと工夫が必要そう。

この辺りもECSがよしなにやってくれると嬉しいので、今後のアップデートに期待。

<br>
<br>

#追加してほしいECS機能
---
- [『The Missing Pieces of Amazon ECS (for me)』](https://speakerdeck.com/takus/the-missing-pieces-of-amazon-ecs-for-me) takas さん

<br>
実装してほしい機能例には確かに！と思うところが多かった。

・ホストで必ず実行するコンテナ(fluentd/datadog-agentなど）をデーモンとして登録する

・クラスタには参加しているがTaskスケジュールさせないホストモード

<br>
などは、確かにあったら便利だ。と切に思った。

未確認ですが、GCP（というかkubanates）ではある機能の模様。

ということで、ぜひAWSさん、ぜひお願いしますw。


<br>
<br>


#まとめ
---

ということで、まとめてみた。

- 待ちに待ったDynamicPort対応ALBは早速採用しているところが多い。
 <br>
- ECSデプロイはGithub - CircleCI デプロイがスタンダードの模様。
 <br>
- デプロイツールは一長一短があるので、今後の開発状況に期待（もしくは自分でPRする）
 <br>
- デプロイ時間に関してはまだ調整の余地はあるので、今後アップデートに期待（もしくは自分で最適解を見つける）
 <br>
- ECSにあったらもっと便利だと思う機能がいくつかあった（AWSへ要望出そう）
 <br>

<br>

以上です。

<br>



#スペシャルサンクス
---
登壇者様たち。

- 『ALB について』 AWSJ 辻さん /『ECS アップデートについて』 AWSJ 岩永さん (@riywo) 
 
- [『Quipper におけるコンテナ今昔物語 - PaaS (Deis/Heroku) を中心に据えた DevOps』](https://speakerdeck.com/hakobera/quipper-on-containers) @hakobera さん 
- 『ECS/CodeDeploy デモ』 @pottava さん 
- [『ECSのデプロイツールを試している話』](https://speakerdeck.com/yukiyan/ecsfalsedepuroituruwoshi-siteiruhua)　ゆきやん さん 
- idobata　さん
- [『Dockerホットデプロイ運用の話』](https://speakerdeck.com/glidenote/operations-for-zero-downtime-docker-deployment)　glidenote　さん
- [『The Missing Pieces of Amazon ECS (for me)』](https://speakerdeck.com/takus/the-missing-pieces-of-amazon-ecs-for-me) takas さん

