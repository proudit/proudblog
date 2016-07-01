---
title: OGPの設定
date: 2016-06-29
tags: facebook,OGP,Open Graph protocol
author: ayako
ogp:
  og:
    description: 'OGPとは、OGPの設定について調べてみました。'
---

#OGPとは&設定方法
---
前回の記事で、facebookシェア機能がとりあえず実行できるようになりましたが、シェアする際のOGP設定がまだできていないため、
シェアをするときに出てくる情報が、こちらの意図しないものになっています。

OGP設定前↓

![OGP設定](./2016/0629_facebookSARE_2/OGP_1.png)


##OGPとは？
OGPとはOpen Graph protocolの略で、「このウェブページは何について書かれていいるのか」という情報を、プログラムから読める形で HTMLに付加する記述方法のこと。
このOGPの設定がされていないと、せっかくシェアしてもらった記事も意図しない内容や画像でアップされてしまい、せっかくシェアしてもらってもきちんとした情報が伝わらないので効果が薄くなってしまいます...

OGPの設定をしない場合、facebookのシステムが勝手に判断した内容を表示してしまいます。

設定の仕方は、HTMLファイルにMETAタグを追記するだけ。

例えば以下のような感じ。

```
<meta property=”og:title” content=”記事のタイトル” />
<meta property=”og:description” content=”記事の説明” />
<meta property=”og:url” content=”記事のURL” />
<meta property=”og:image” content=”画像のURL” />
<meta property=”og:site_name” content=”サイトのタイトル” />
```

##注意するべき画像の仕様

OGPに設定する画像についてはいくつかおさえておきたい仕様があります。
適切な画像を指定してより目にとまりやすくなるようにしたいですよね。
　
・画像サイズ
　推奨サイズ　1200×630ピクセル
　最低でも600×315ピクセル必要

・縦横比率
　1.91：1

・画像の指定は相対パスではなく絶対パスで記述


指定した画像がどのように表示されるのか、事前に確認することもできます。

OGP画像シュミレータ
http://ogimage.tsmallfield.com/


#OGPのキャッシュをクリアする

METAタグを追加してもなぜか、情報が更新されません。

OGPの設定がされているかfacebookのデバッガーで確認をしてみます。

https://developers.facebook.com/tools/debug/
![OGP設定](./2016/0629_facebookSARE_2/OGP_2.png)

情報更新されていないです...タグの設定ミスかな...なんて思いながら、調べてみると
facebookのデバッガーからキャッシュをクリアすることができるそうで、
早速やってみました！

Open Graph Object Debugger
https://developers.facebook.com/tools/debug/og/object/
![OGP設定](./2016/0629_facebookSARE_2/OGP_3.png)

![OGP設定](./2016/0629_facebookSARE_2/OGP_5.png)
ちゃんと画像も指定したものが表示されていて、サイト名もPloudBlogの表示が！
実際にブログサイトからシェアしてみると...

![OGP設定](./2016/0629_facebookSARE_2/OGP_4.png)

こちらも情報が更新されていますね。
ただ、、一部おかしなところがあります...(汗)

この部分は、記事ごとに内容が変わるように設定しかったので、変数を入れてみたのですが、きちんとデータの取得ができていないですね。

多くのサイトではおそらくPHPを使ってデータ取得の設定をしているようですが、、JavaScriptあたりで同じことができないか今模索中です。。

wordpressはプラグインでこう言った設定ができるようです

ここは引き続き調べていきます！
facebookの設定けっこう難しいです...


