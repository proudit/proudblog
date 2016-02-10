---
title: GitHubとCircleCIを連携させよう！！
date: 2016-02-09
tags: GitHub, CircleCI
author: kohei
---

# はじめに
CircleCIは継続的インテグレーション(Continuous Integration)を行うためのWebサービスです。
指定したGitHubリポジトリをウォッチし、更新があると自動でビルド〜デプロイを行える仕組みを作れます。
とりあえず今回は初めのGitHubとCircleCIを連携させるところを行います。

# 事前準備
・[GitHubアカウントの取得](../../../2016/02/01/regist-gihub.html)
CircleCIを利用するにはGitHubアカウントが必要となります。

# 連携設定
#### 1.ログイン
[Circleci](https://circleci.com/)へアクセスし「Sign in」をクリックします。
![20160125_circleci01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/7dfec881-aa24-9e8c-05d0-1102f5e1fe38.png)

#### 2.GitHubログイン
ログイン画面が表示されるので事前に準備したGitHubアカウントへログインします。
![20160125_circleci02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/f592d016-db70-bb23-13cd-ff4fa87dc3f7.png)

#### 3.認証
認証画面が表示されるため、「Authorize application」をクリックします。
![20160125_circleci03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/e216dafa-2cdb-ed89-37c3-e959ce58a43e.png)

#### 4.アカウントの選択
CircleCIと連携するGitHubアカウントを指定します。
![20160125_circleci04.png](https://qiita-image-store.s3.amazonaws.com/0/82090/26c3a9d3-a7c8-8260-d2fe-407f3c8ef8ed.png)

#### 5.リポジトリの選択
アカウントを指定すると、リポジトリがリストされるので連携したいリポジトリの「Build project」をクリックします。
![20160125_circleci05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/73519472-6b06-00d4-10f5-9154aa2a8836.png)

#### 6.プランの選択
利用するプランを指定します。
![20160125_circleci07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b7b01720-8410-392c-1a1c-5ccdd2f992af.png)

#### 7.完了
以上で連携が完了です。
![20160125_circleci08.png](https://qiita-image-store.s3.amazonaws.com/0/82090/bcd9bede-56ab-605d-7a93-8ba705802215.png)



# 最後に
以上、今回はGitHubとCircleCIを連携させる部分だけ行いました。
実際にデプロイまで行うには_circle.yml_というファイルを使って管理する必要があります。
そこについては、また時間があるときに書ければと思います。

