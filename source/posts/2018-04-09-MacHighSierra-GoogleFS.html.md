---
title: Mac High SierraでGoogleファイルストリームがエラーになる時の対処
date: 2018-04-09
tags: Mac,
author: ayako
ogp:
  og:
    description: ''
---


以前から使用していたgoogleドライブのサポートが終了するということで、現在はGoogleドライブファイルストリームの提供がされています。

ただ、なぜかアプリをダウンロードして起動してもエラーになってしまい起動してくれない。

アンインストールしてから再インストールしても状況は変わらず、ログインしてもしばらくしてファイルストリームが停止してしまいます....。

![gdriveエラー.png](https://qiita-image-store.s3.amazonaws.com/0/174392/56e6a949-5e63-5dc6-e30e-a982ee1c6153.png)

#Mac High Sierraを使用中の場合はある設定が必要
---

Mac OS 10.13（High Sierra）でドライブファイルストリームを使用するには、以下の設定が必要です。

まずファイルストリームを開き、左上アップルアイコン　＞　システム環境設定　
![GFS01.png](https://qiita-image-store.s3.amazonaws.com/0/174392/8b0e58da-cdbd-8caf-f1b2-71ef3d1aaf79.png)

セキュリティとプライバシー

![GFS02.png](https://qiita-image-store.s3.amazonaws.com/0/174392/299ea0a6-2972-a0ed-c1c9-81935414812a.png)

一般タブの下部に「開発元"Google, Inc."のシステムソフトウェアの読み込みがブロックされました。」と表示されているので、ここを[許可]します。

※今回設定した後だったため、文字入れしてます

![GFS03.png](https://qiita-image-store.s3.amazonaws.com/0/174392/b932cebc-db4c-679b-3c40-95bddd94edfd.png)

これでファイルストリームに無事ログインできるようになりました。

#ファイルストリームにログインする
---

ファイルストリームを開くと、Googleドライブと同じく画面上部にアイコンが表示されるのでクリックしてgoogleアカウントでログイン。

![GFS04.png](https://qiita-image-store.s3.amazonaws.com/0/174392/d0221247-dbeb-c2a6-c148-ccdd456e1e11.png)

ログインするとアカウントの右横にフォルダマークが表示され、クリックするとフォルダが表示されます。

![GFS05.png](https://qiita-image-store.s3.amazonaws.com/0/174392/086d69dd-7110-e07d-090a-5291a85a7861.png)

マイドライブの方で、同期されたファイルが全て確認できます。

![GFS06.png](https://qiita-image-store.s3.amazonaws.com/0/174392/b4cd5c5f-5190-9a46-d644-e632425d3dfe.png)


#Googleドライブをアンインストールする
---

ファイルストリームでファイルの同期が確認できた後、今までのGoogleドライブは不要になるので、アンインストールしてしまいます。

![GFS07.png](https://qiita-image-store.s3.amazonaws.com/0/174392/a023a90a-d53a-a78f-02d1-fb80b3c778f9.png)

Finderでアプリケーションフォルダを開き、Googleドライブを削除します。

サイドバーに残っているGoogleドライブの項目も削除。
この時点でファイルストリーム上にフォルダが存在していることを再度確認しましょう。

以上でGoogleドライブからファイルストリームへの切り替えが完了しました。




