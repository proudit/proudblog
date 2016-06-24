---
title: facebookへのシェアができない！？〜アプリ設定の方法〜
date: 2016-06-24
tags: facebook,blog
author: ayako
---

#はじめに
---

このPloudBlogについていたfacebookへのシェア機能、実は今までちゃんと
機能していませんでした(汗)

どういう状態だったかというと...シェアをクリックすると！

```
アプリが設定されていません: This app is still in development mode, and you don't have access to it. Switch to a registered test user or ask an app admin for permissions.
```

というエラーが出ていたんです...(´°ω°)ﾁｰﾝ

実は、サイトをシェアするには、サイト側のコードにfacebookで取得したコードを書き込むことに加え、サイトとfacebookをリンクさせる必要があるのです！


#アプリ設定の仕方
---
まず、以下サイトへアクセス。

https://developers.facebook.com/apps

右上の登録ボタンからfacebook開発者への登録を許可する

![アプリ設定](./2016/0624_facebookSARE/appConfiguration_02.png)

![アプリ設定](./2016/0624_facebookSARE/appConfiguration_03.png)

開発者への登録が完了すると、Add a New Appのページが出てくるので、
ここからリンクさせたいサイトの設定を行います。

![アプリ設定](./2016/0624_facebookSARE/appConfiguration_04.png)

該当のサイト名等を画面に従って入力していきます。

![アプリ設定](./2016/0624_facebookSARE/appConfiguration_05.png)


![アプリ設定](./2016/0624_facebookSARE/appConfiguration_06.png)

設定が完了すると下記のように、該当サイトの設定ページが出てきます。
現在、ploudblogは公開ステータスとなっていますが、この部分は初期の段階では
一般に対しては未公開となっているので、ここを公開ステータスへ変更。
公開ステータスへの変更は画面左のメニューバー、アプリレビューより。

![アプリ設定](./2016/0624_facebookSARE/appConfiguration_07.png)

公開しますか？→はいに変更して、完了です！

![アプリ設定](./2016/0624_facebookSARE/appConfiguration_08.png)

これで無事ブログのシェア機能が使えるようになりました〜！
ただ、今の状態だとどのページでシェアをしても、同じ記事内容＆画像が出てきてしまうのです...

恐らくOGP（Open Graph protocol）の設定する必要があるので、
これについてはまた別途進めていこうと思います。
