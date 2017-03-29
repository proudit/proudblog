---
title: ActiveDirectory ユーザ追加方法(管理画面)
date: 2017-03-29
tags: ActiveDirectory,
author: ayako
ogp:
  og:
    description: ''
---

#ユーザ追加方法

先日dsaddコマンドでのユーザ追加についてまとめましたが、
備忘録として管理画面からの追加方法もまとめてみます。

スタート　＞　管理ツール　＞ActiveDirectory　ユーザとコンピューター

![adduser](./2017/0329_adduser/adduser_01.png)

Usersフォルダにて右クリック　＞　新規作成　＞　ユーザ

![adduser](./2017/0329_adduser/adduser_02.png)

＜TestUser01＞というユーザを作ってみます。
実際は姓・名の部分に名前を入れます。

![adduser](./2017/0329_adduser/adduser_03.png)

パスワードを入力。
デフォルトで、ユーザは次回ログオン時にパスワード変更が必要にチェックが入っていますが、チェックを外しています。
必要に応じてチェックを外す、そのままにするどちらかでご対応ください。

![adduser](./2017/0329_adduser/adduser_05.png)

登録したユーザをグループに追加させたい場合は、ユーザとコンピューター一覧の対象のユーザを
右クリック　＞　プロパティ　＞　所属するグループ
から追加させたいグループを選択すればOKです。

#新規作成したユーザをリモートデスクトップ接続するには
---
ポリシーで接続許可を入れていなければ、デフォルトの状態ではおそらく接続ができません。
リモートデスクトップの接続許可設定が必要です。

スタート　＞　コンピュータ　＞　右クリック　＞　プロパティ

![adduser](./2017/0329_adduser/adduser_06.png)

設定の変更

![adduser](./2017/0329_adduser/adduser_07.png)

ユーザの選択

![adduser](./2017/0329_adduser/adduser_08.png)

リモート接続を許可したいユーザを追加。

![adduser](./2017/0329_adduser/adduser_09.png)


これで完了です。

