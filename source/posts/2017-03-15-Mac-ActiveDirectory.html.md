---
title: Macのドメイン参加手順について
date: 2017-03-15
tags: ActiveDirectory,Mac
author: ayako
ogp:
  og:
    description: 'Mac環境ADユーザでログインできるように設定を行います。'
---

#はじめに
---
前提条件
ドメイングループ内に対象のユーザアカウントを作成する。
尚、今回のActive DirectoryはAWSのMicrosoft AD環境での作業です。


###コンピューターのドメイン参加とは

```
管理するActive Directory配下で利用したいコンピューターをドメインに参加させ、ドメイン内の他のコンピュータと共通のアカウントなどを利用できるようにすること。
```

##ドメイン参加手順

必要な情報：Active Directoryで作成されたユーザアカウント。
　　　　　またそれに紐付いたコンピューター名。
　　　　　
　　　　　
①対象のMacにローカル管理者権限があるユーザでログインする			
②DNS設定			
システム環境設定　＞　ネットワーク　＞　詳細　＞　DNS　＞　検索ドメイン(ドメインを追加)			

![macドメイン](./2017/0315_macAD/macAD_01.png)

![macドメイン](./2017/0315_macAD/macAD_02.png)



システム環境設定 ＞　ユーザーとグループ　＞　ログインオプション　＞接続...  ＞　ActiveDirectoryを選択

![macドメイン](./2017/0315_macAD/macAD_03.png)

![macドメイン](./2017/0315_macAD/macAD_04.png)

ActiveDirectoryのドメイン：xxxx.intra
コンピュータIDを入力しバインドへ

![macドメイン](./2017/0315_macAD/macAD_05.png)

![macドメイン](./2017/0315_macAD/macAD_06.png)

ここで入力するユーザ名とPWについて、注意することがあります。
前提条件でユーザ登録と合わせて、コンピューター名の登録とユーザとの紐付けが必要と前述しました。

コンピューター名の登録とユーザとの紐付けを行わない場合、
Administrator権限の入力をしなければ認証ができないようになっています。
Administrator権限の情報を安易に周知したくない場合がほとんどだと思うので、事前のコンピューター名、ユーザアカウントとの紐付けがおすすめです。


###注意点

この状態では端末の管理者権限が付与されておらず、アプリのインストールや設定変更が行えないことがあるため、管理者権限を付与する。

管理　＞　管理を許可するユーザ：にチェックを入れ、xxxx.intraを追加する

![macドメイン](./2017/0315_macAD/macAD_07.png)

これでMACからAD環境へのアクセスができるようになりました。

###ログアウトせずにMACでユーザを切り替える方法

今回このドメイン参加の方法を検証するにあたって、自身のMACを使っていたわけですが。
ADで作成したユーザアカウントでMACにログインできるかテストする際、
いちいちログアウトするのがとても面倒だったので、簡単にアカウントを切り替える設定をご案内します。

システム環境設定　＞　ユーザとグループ　＜　クリックして編集を可能にし　＞　ログインイプション

ファストユーザスイッチメニューを表示にチェックを入れる。

![macドメイン](./2017/0315_macAD/macAD_08.png)

そうすると、画面の右上にアイコンが表示される。
これでいちいちログアウトしなくても、アカウントを素早く切り替えて作業することができます〜。

![macドメイン](./2017/0315_macAD/macAD_09.png)

[microsoft公式サイトより](https://www.microsoft.com/japan/msbc/Express/sbc/activedirectory/default.aspx)




