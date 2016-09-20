---
title: Flockerについて
date: 2016-09-20
tags: Docker
author: kohei
ogp:
  og: 'FlockerはClusterHQからリリースされた、Dockerのボリュームやコンテナの管理ができる
オープンソースツールです。Dockerのデータボリュームをクラスタ間でマイグレーション
ができるということで、とても興味深かったので調べてみました。'
---

#| はじめに
FlockerはClusterHQからリリースされた、Dockerのボリュームやコンテナの管理ができるオープンソースツールです。Dockerのデータボリュームをクラスタ間でマイグレーションができるということで、とても興味深かったので調べてみました。
今回は、[ClusterHQ](https://clusterhq.com/)のサイトにある[ABOUT FLOCKER](https://clusterhq.com/flocker/introduction/)を自分なりの言葉で訳しています。


<br>
#| FLOCKERとは？

![flocker_logo.png](https://qiita-image-store.s3.amazonaws.com/0/82090/69d1780a-e636-6cf9-40a7-7d5e550a476f.png)

Flockerはdocker環境で利用するために作られた、データボリュームを管理するオープンソースのツールです。

データ移行ツールによって、Flockerはデータベースなどのステートフルサービスを利用するために必要となるツールを提供します。

単体サーバに縛られたDockerデータボリュームではなく、データセットと呼ばれるFlockerのデータボリュームはクラスタ内にあるコンテナであれば自由に移動ができます。

![alt](https://clusterhq.com/assets/images/diagrams/diagram-1.jpg)

FlockerはDockerコンテナとデータボリューム両方一緒に管理します。Flockerでマイクロサービスを管理すれば、クラスタ内の別のホストへコンテナとボリュームをセットで移動できます。


<br>
#| Flocker操作
FlockerはシンプルなREST APIを使います。Flockerコントロールサービスはクラスタ内の各ノード上で動いているFlockerエージェントと通信してコマンドを実行します。

ほとんどの場合、DockerのFlockerプラグインでFlockerを利用でき、DockerコマンドラインでFlockerを操作できます。多くの複雑な操作も、CLIツールを使うことで直接Flockerを操作できます。もし、FlockerをGo言語のようにプログラムで操作したいなら、PythonまたはRubyでAPIを利用することができます。

Flockerクラスタ上で起こっていることを知りたい時は、データセットとログを調べるためにVolumeHubを利用してください。

![alt](https://clusterhq.com/assets/images/diagrams/diagram-2.jpg)


<br>
#| オーケストレーションとストレージインテグレーション
Flockerはアプリケーションがディストリビューションでもビルドでも動くように設計されています。DockerのFlockerプラグインのおかげで、FlockerはDocker EngineやDocker Swarm、Docker Composeといった有名なコンテナ管理ツールやオーケストレーションツールでも利用できます。

![alt](https://clusterhq.com/assets/images/diagrams/diagram-4.jpg)

ストレージといえば、FlockerはAmazon EBSやRackspace Cloud Block Storage、EMC ScaleIOのようなブロック単位の共有ストレージもローカルストレージと同じようにサポートします。
なので、アプリケーションにとってベストなストレージを選ぶことができます。
ベストなストレージを選ぶことについてはこちらを参照ください。
多くのプロバイダが提供するような前もって決まっているストレージをFlockerで利用することも可能です。Flockerストレージのサポート情報はこちら。

---
<br>
# FIND OUT MORE - 60秒でFlocker

これはFlockerについて紹介した1分間ビデオです。
[![alt](http://img.youtube.com/vi/dcSfhncZ2Dk/0.jpg)](http://www.youtube.com/watch?v=dcSfhncZ2Dk)

***

<br>
#| ストレージオプションは？

Flockerは共有ストレージ(Amazon EBSやEMC ScaleIO)でもローカルストレージでも利用できます。ベストオプションはやろうとしていることやアプリケーション次第です。どのストレージオプションが良いかは下のチャートを利用してください。もしFlockerを評価したいのならこちらに連絡してください。



|推奨要件|共有ストレージ|ローカルストレージ(Experimental)|
|---|---|---|
|サポートストレージ	| AWS Elastic Block Storage (EBS),<br> OpenStack Cinder with any supported backend, EMC ScaleIO,<br> EMC XtremIO,<br> VMware vSphere and vSan,<br> NetApp OnTap,<br> Dell Storage SC Series,<br> HPE 3PAR StoreServ and StoreVirtual (with OpenStack only),<br> Huawei OceanStor,<br> Hedvig,<br> NexentaEdge,<br> ConvergeIO,<br> Saratoga Speed | ローカルディスクを含む全般 |
|サポートクラウドプロバイダとオンプレ環境| AWS,<br> Rackspace,<br> OpenStack private clouds,<br> private data centers with a supported storage environment | Linux環境全般 |
|物理または仮想ホストあたりの最大データボリューム数| 約25程度<br> *ただしクラウド環境によります | 100-1000程度<br> *ただし構成によります |
| データボリュームマイグレーション(同データセンター内のサーバ間) | ○ | ○ |
| データボリュームマイグレーション(異なるデータセンター内のサーバ間) |  | ○ |
| データセンター内のフェイルオーバーサポート[^1] | ○ |   |
|Flocker API| ○ | ○ |
|Flocker CLI| ○ | ○ |
|サポートファイルシステム| Ext4 | ZFS |
|サポートOS| Ubuntu, CentOS 7, CoreOS (coming soon) | Ubuntu, CentOS 7, CoreOS (coming soon) |


このテーブルは以下の条件を満たす場合に限ります。
・VMが同じEBSボリュームにアクセスできること。(AWS)
・VMが同じOpenStack Cinder backendに接続できること。(OpenStack)
・サポートされた同じ物理ストレージアレイに接続できること。

***

<br>
# FIND OUT MORE - Flockerのストレージオプションを理解する

Amazon EBSのような共有ストレージオプションやZFSのローカルストレージを利用したFlockerについて学ぶことができます。
[![alt](http://img.youtube.com/vi/39wmAaUT2Y4/0.jpg)](http://www.youtube.com/watch?v=39wmAaUT2Y4)

