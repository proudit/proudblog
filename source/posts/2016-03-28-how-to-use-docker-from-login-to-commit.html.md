---
title: Dockerコンテナのリポジトリ管理　DockerHubへログイン、イメージの取得〜更新、コミットまで。
date: 2016-03-28
tags: docker, DockerHub
author: kohei
---

# はじめに
今回はDockerHubでのプライベートリポジトリ管理（手動）を想定しました。
まずはDockerHubへログインした上でリポジトリからコンテナをpullで取得し、その後コンテナ自身を更新します。その後commit→pushでDockerHubにあるリポジトリを更新します。
以上が「コンテナか管理」の際に行う基本的な流れになると思います。

<br>
# 1.DockerHubへのログイン
まずはリポジトリへアクセスできるようにするため、DockerHubへログインを行います。

```bash:DockerHubへログイン
$ docker login
Username: kohei
Password:
Email: kohei@hogehoge.jp
WARNING: login credentials saved in /Users/kohei/.docker/config.json
Login Succeeded
```

<br>
# 2.コンテナのpull
ローカルリポジトリに存在するdocker imageを確認します。

```bash:現状の確認
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
```
現在はローカルリポジトリにはimageが存在しないため何もリストされていません。
確認ができたら`$ docker pull リポジトリ:タグ`でDockerHubからimageを取得します。

```bash:コンテナの取得
$ docker pull kohei/httpd:ver1.0
ver1.0: Pulling from kohei/httpd
a2c33fe967de: Pull complete
d3bf674be7aa: Pull complete
13bab7291cec: Pull complete
e87afdecef01: Pull complete
4cf71c080937: Pull complete
Digest: sha256:5b940d5b742317185db6b1d25b06e6e68060b08f8fdd53f36a6bd6d471bd7043
Status: Downloaded newer image for kohei/httpd:ver1.0
```
再度`$ docker images`を実行すると、先ほどpullしたimageが取得できているのが確認できます。

```bash:取得後の確認
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
kohei/httpd         ver1.0              4cf71c080937        2 days ago          264.3 MB
```

<br>
# 3.コンテナの更新
imageが取得できたのでコンテナを更新します。

```bash:コンテナの起動
$ docker run -it kohei/httpd:ver1.0 /bin/bash
```
コンテナを起動してパッケージのインストールやconfの修正などを行います。
修正が完了したらexitでコンテナから抜けて停止させます。


<br>
# 4.イメージの作成
修正したコンテナの`CONTAIER ID`を確認します。

```bash:コンテナの確認
$ docker ps -a
CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS                      PORTS               NAMES
b10edb89cd05        kohei/httpd:ver1.0   "/bin/bash"         43 seconds ago      Exited (0) 12 seconds ago                       gloomy_khorana
```
確認したら、`$ docker commit -m "コメント" <コンテナID> <リポジトリ:タグ>`でローカルリポジトリへコミットします。

```bash:コンテナのコミット
$ docker commit -m "edited container" b10edb89cd05 kohei/httpd:ver1.0
02607c25ed22c085a8e4964c91406baa911f194265db5d4ddfd44a2f96e799ec
```
完了したら再度`$ docker images`で`IMAGE ID`を確認します。

```bash:コンテナイメージの確認
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
kohei/httpd         ver1.0              02607c25ed22        5 seconds ago       264.3 MB
```
すぐに確認すれば`CREATED`が数秒前という記載になっています。また、コミットする前に確認した`IMAGE ID`は異なるIDになっています。

<br>
# 5.コンテナのpush
ローカルリポジトリへコミットが完了したらDockerHubへpushします。

```bash:DockerHubへpush
$ docker push kohei/httpd:ver1.0
The push refers to a repository [docker.io/kohei/httpd] (len: 1)
02607c25ed22: Pushed
4cf71c080937: Image already exists
e87afdecef01: Image already exists
13bab7291cec: Image already exists
d3bf674be7aa: Image already exists
ver1.0: digest: sha256:fb10c3626b1fc732c314efc132a29f7ee37c52176547a076c72553a97eaee949 size: 9116
```

以上で完了です。

<br>
# おわりに
コンテナ中身の更新方法はいろいろあるのでとりあえずrunで起動しての修正にしてます。
ただ、この一連の流れ(login〜pull〜commit〜push)はコンテナを管理する立場の人にはルーティン作業になると思ったのでメモとしてまとめました。
loginは一度ログインしてしまえば不要ですが、複数アカウントをまたぐ可能性がある場合はポイントになると思います。

