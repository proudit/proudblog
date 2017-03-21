---
title: ActiveDirectory dsaddコマンドでユーザ追加
date: 2017-03-21
tags: ActiveDirectory,
author: ayako
ogp:
  og:
    description: ''
---

#はじめに
---
AD環境内に数百人分のユーザ追加をするミッションに挑戦。
そこで！バッチファイルでの実行をおこなうことになりました。
その前に、dsaddコマンドが実行できるか検証です。

登録するユーザ情報
ドメイン名：proudit.intra
ユーザーアカウント名：テスト太郎
所属グループ：testG

この情報を各項目に当てはめていきます。

それぞれのオプションが実際にどこの情報になるのかはこちら。

![dsadd](./2017/0321_dsadd/dsadd_01.png)

![dsadd](./2017/0321_dsadd/dsadd_02.png)


```
成功したコマンド：
dsadd user “CN=テスト太郎,OU=Users,OU=proudit,DC=proudit,DC=intra” -samid testtaro -fn 太郎 -ln テスト -display テスト太郎 -upn testtaro@aproudit.intra -memberof “CN=testG,OU=Users,OU=proudit,DC=alim,DC=intra” -pwd Ma57tUgv -disabled no
```


```
失敗したコマンド
dsadd user “CN=テスト太郎,OU=Users,DC=proudit,DC=intra” -samid testtaro -fn 太郎 -ln テスト -display テスト太郎 -upn testtaro@alim.intra -pwd Ma57tUgv  -disabled no
```
はじめのうちは、エラーばかり。。
```
dsadd 失敗:CN=テスト太郎,OU=Users,DC=proudit,DC=intra:サーバーにそのようなオブジェクトはありません。
```

既に登録済みのーユーザ情報がどのようなオブジェクトで登録されているのかをチェック！

①全てのADアカウント情報をファイル出力

```
csvde -u -f export.csv

CN=testuser01,OU=Users,OU=proudit,DC=proudit,DC=intra,user,"CN=testuser01,OU=Users,OU=alim,DC=alim,DC=intra"......
```
失敗したコマンドでは、OUの指定の仕方が間違っていたようです。

>CN=テスト太郎,OU=Users,DC=proudit,DC=intra

OU=Usersと合わせて、OU=prouditが必要でした。

>CN=テスト太郎,OU=Users,OU=proudit,DC=proudit,DC=intra

##エクセルでコマンドを一括作成
無事dsaddコマンドでの登録に成功したので、Excelを使ってユーザ分のコマンドを作ります。
↓の数式をセルに貼り付け。

```
="dsadd user "CN="&B15&",OU=Users,OU=proudit,DC=proudit,DC=intra" -samid "&E1&" -fn "&D15&" -ln "&C15&" -display "&B15&" -upn "&E15&"@proudit.intra -pwd "&Z1&" -disabled no"
```
ここではまったこと。

・“”でくくると数式エラーになる
値の中に文字列がが入っているので、
"CN="&B15&",OU=Users,OU=proudit,DC=proudit,DC=intra"
とするとエラーになってしまうようです。

なんとかオブジェクト部分のダブルコーテーションを文字列としようと悪戦苦闘しましたが、最終的にダブルコーテーションをシングルコーテーションに変換して、解決。

コマンドラインでもダブルコーテーションでなくシングルコーテーションで動作に問題はありませんでした。

##バッチファイルの作成
作成したコマンドをコピペしてバッチファイルを作成。

この時まず気をつけること。

・文字コードはShift-Jis
・mac環境の場合は、AD環境下でファイルを作成する

ここでのはまりごと。
・バッチファイルを介してのコマンドを実行する場合、シングルコーテーションだとエラーになる。

・知らぬ間にスペースが入ってしまい、エラーになる。

エディタの置換機能で、シングルコーテーションをダブルコーテーションへ。
不要スペースを削除。

これでバッチファイルの完成。ファイルを実行して完了です。


#おわりに
さらっとまとめましたが、
ちょっとしたスペース(空白)やシングルコーテーション、ダブルコーテーションに翻弄され、完了までに結構な時間が掛かりました・・・。
ということでまた次回。
