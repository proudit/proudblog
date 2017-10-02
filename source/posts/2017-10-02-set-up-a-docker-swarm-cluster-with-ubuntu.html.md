---
title: "UbuntuでDocker Swarmクラスタをセットアップする。"
date: 2017-10-02
tags: Docker, Swarm, Ubuntu 
author: kohei
ogp:
  og: 'Ubuntu 16.0.4 のサーバーを3台用意してそれを Docker Swarm でクラスタを組んだのでそれをまとめました。'
---

# はじめに
_Ubuntu 16.0.4_ のサーバーを3台用意してそれを __Docker Swarm__ でクラスタを組んだのでそれをまとめました。

![docker-whales-transparent.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7396fe59-5abf-b7d6-1d9a-5fda0f3353a7.png)


<br>
# 構成
今回行う構成は3台とも _manager&worker_ でクラスタを組む構成です。

**イメージ**
![docker-swarm.png](https://qiita-image-store.s3.amazonaws.com/0/82090/20674ff2-71bc-acdf-52e0-2855bc814e7d.png)


<br>
# Dockerインストール
とりあえず全てのサーバーに _docker-engine_ をインストールします。

**イメージ**
![スクリーンショット 2017-09-29 13.22.14.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9528d0e4-ac96-1cc2-726b-748401a2ab37.png)


まず、aptをhttps越しで利用できるようにするためのライブラリをインストールします。

```bash:必要ライブライのインストール
$ sudo apt-get install apt-transport-https ca-certificates
```

次に _docker_ のインストールに使うリポジトリを追加します。

```bash:リポジトリ追加
$ sudo vim /etc/apt/sources.list.d/docker.list

$ cat /etc/apt/sources.list.d/docker.list
deb https://apt.dockerproject.org/repo ubuntu-xenial main
```

```bash:apt更新
$ sudo apt-get update
```

準備できたら _docker-engine_ をインストールします。

```bash:dockerインストール
$ sudo apt-get install docker-engine
```

今回使うわけではないですが、_docker compose_ もインストールしておきます。

```bash:composeインストール
$ apt-get install docker-compose
```


<br>
# master(Leader) nodeの作成
今回は3台とも _manager node_ にします。まずは _manager_ の _master_ となる１台を作成します。

**イメージ**
![スクリーンショット 2017-09-29 14.21.34.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9fb9084d-13d7-740b-c3cb-c41764f742a4.png)

```bash:manager(Leader)作成
$ docker swarm init 
Swarm initialized: current node (71uuiqwvlcizxln4bfk3gvr4a) is now a manager.

To add a worker to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-0ymf7p2vy09a15usvwbb6ya04hqg7b0aaupj0xp3vfy137nrhr-5k87wh49qn3j7ml6b8kxiz5t7 \
    172.31.17.88:2377

To add a manager to this swarm, run 'docker swarm join-token manager' and follow the instructions.
```

ここで _init_ した際に出てくるのは _worker_用の _token_ です。今回は _manager_用の _token_ が欲しいので以下のコマンドを実行して取得します。

```bash:manager用token取得
$ docker swarm join-token manager
To add a manager to this swarm, run the following command:

    docker swarm join \
    --token SWMTKN-1-0ymf7p2vy09a15usvwbb6ya04hqg7b0aaupj0xp3vfy137nrhr-0blrkkwxwghkddo7hk5tkcy2y \
    172.31.17.88:2377
```

これであとは各ノードとなるサーバーへログインし、追加していく作業となります。


<br>
# nodeへの参加

それでは _node-2_ を先ほど作成した _manager node_ に追加します。

**イメージ**
![スクリーンショット 2017-09-29 13.26.12.png](https://qiita-image-store.s3.amazonaws.com/0/82090/79383358-9a2b-7b9a-134d-4f12c9a112bd.png)

```bash:manager(Leader)へnode追加
$ docker swarm join --token SWMTKN-1-0ymf7p2vy09a15usvwbb6ya04hqg7b0aaupj0xp3vfy137nrhr-0blrkkwxwghkddo7hk5tkcy2y 172.31.17.88:2377
This node joined a swarm as a manager.
```

これで、追加されました。残りの１台も同様に追加します。

もし、 manager ではなく _worker_ として追加したい場合は __--token__ オプションの値を _worker_ のにしてあげるだけでOKです。 

以上で完了です。それでは確認してみましょう。

```bash:node確認
$ docker node ls
ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
71uuiqwvlcizxln4bfk3gvr4a *   node-1              Ready               Active              Leader
musl2m94jqx7gb0fa953rd43j     node-3              Ready               Active              Reachable
nwhmqq24zkvgbxlbsq8zut4vo     node-2              Ready               Active              Reachable
```

ここで「*」が付いているのがコマンドを実行したnodeです。つまりここでは _node-1_ で `docker node ls` を実行したということです。
また、 __MANAGER STATUS__ が _Leader_ となっているのがはじめに `swarm init` した _master_ となる _node_ で _Reachable_ となっているのが追加した _node_となります。もし、 _worker_ として node を追加した場合は、ここの項目は _blank_ になります。


<br>
# デプロイ
クラスタが組めたので、何かデプロイしてみます。
今回は _nginx_ のコンテナをデプロイしてみました。

```bash:デプロイ
$ docker service create --replicas 1 --name web -p 80:80 nginx
zelm5elrp6czm1mtisk942ujx
```

デプロイができたらサービスを確認してみます。

```bash:デプロイ確認(サービス)
$ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
zelm5elrp6cz        web                 replicated          1/1                 nginx:latest        *:80->80/tcp
```

```bash:デプロイ確認(コンテナ)
$ docker service ps web
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
mjbwdr63zfyo        web.1               nginx:latest        node1               Running             Running 3 minutes ago                       
```

_node1_ で nginx コンテナが1台　_web_ というサービス名で起動しているのが確認できました。
それではこのサービスをコンテナ3台にスケールしてみます。

```bash:スケール
$ docker service scale web=3
web scaled to 3
```

```bash:スケール確認
$ docker service ps web
ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE             ERROR               PORTS
mjbwdr63zfyo        web.1               nginx:latest        node1               Running             Running 4 minutes ago                         
jmm52jos2vgl        web.2               nginx:latest        node3               Running             Running 8 seconds ago                       
sbpa751k6wwa        web.3               nginx:latest        node2               Running             Running 8 seconds ago                       
```

各nodeに1台ずつコンテナが起動しているのが確認できました。


<br>
# おわりに
最近は [kubernetes](https://kubernetes.io) が盛り上がっているみたいですが、
 _Swarm_ もそんなに利用勝手は悪くなさそうです。 _compose_ のymlもそのまま利用できますし、どれを使うかは場合によりけり何だろうなと思います。

