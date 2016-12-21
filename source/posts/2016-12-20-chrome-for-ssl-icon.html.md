---
title: Chromeブラウザに表示されるSSLアイコンについて。
date: 2016-12-20
tags: SSL
author: kohei
ogp:
  og: '先日、https://blog.proudit.jpのサイトURLがいつもと違うのに気づきました。'
---

# はじめに
先日、[https://blog.proudit.jp]()のサイトURLがいつもと違うのに気づきました。
通常SSLが導入されているサイトにChromeでアクセスするとURL欄に緑色の鍵マーク![lock.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b40929f4-e811-187f-0559-2d64b6661342.png)が表示されると思いますが、![info.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fdfe296e-64c9-2070-05a6-bead94ae23c7.png)のマークになっていました。
![ssl-url.png](https://qiita-image-store.s3.amazonaws.com/0/82090/8411a031-40aa-6fdc-f896-ffb9f1a89832.png)

ちょっと、気になって調べてみたところ、アイコンは３種類(![lock.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b40929f4-e811-187f-0559-2d64b6661342.png) ![info.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fdfe296e-64c9-2070-05a6-bead94ae23c7.png) ![unnamed.png](https://qiita-image-store.s3.amazonaws.com/0/82090/293418fe-e323-cc47-e21d-d54ad90ccd3b.png))あるみたいです。


<br>
# SSLアイコンについて
アイコンの詳しい内容については[Chromeヘルプ](https://support.google.com/chrome/answer/95617?hl=ja)に載っていますがざっとまとめると以下のような感じです。


<br>
## ロック ![lock.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b40929f4-e811-187f-0559-2d64b6661342.png)
このサイトへの接続はプライベート接続で正常な状態となります。
サイトの証明書が有効で、Chromeとサイトの間で暗号化接続がちゃんと確立されていることを示します。また、サイトへ送信する情報はプライバシー保護がされます。


<br>
## 情報 ![info.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fdfe296e-64c9-2070-05a6-bead94ae23c7.png)
このアイコンは２つの場合が考えられます。

##### **| このサイトへの接続はプライベート接続ではありません。**
この場合はサイトからHTTPS証明書が送信されていない状態です。
つまり接続が暗号化ができていないことになります。
この場合、パスワードやクレジットカードなどの機密情報は入力しないように気をつけましょう。

##### **| このサイトへの接続はプライベート接続です。ただし、ネットワーク上のユーザーがこのページのデザインを変更できる可能性はあります。**
サイトとの間はプライベート接続はされているので基本的には暗号化はされています。ただ、一部のコンテンツでHTTPSが使用されていない(HTTPが使用されている)ため、その部分では接続に暗号化がされていません。
つまり、そのサイト内でリンクを貼っていたりする場合、URLが**http://**で指定されていたりする可能性があります。


<br>
## 警告 ![unnamed.png](https://qiita-image-store.s3.amazonaws.com/0/82090/293418fe-e323-cc47-e21d-d54ad90ccd3b.png)
サイトへの接続が適切に暗号化されていない場合に発生します。
期限が切れていいたり、証明書のドメインがサイトのドメインと異なるなど、証明書が不正な場合に発生します。
また、この表示がされるサイトは危険なサイトであるか、個人情報や機密情報を騙し取る虚偽サイトである可能性があります。
とにかく気をつけましょう。


<br>
# 確認
今回の場合、情報アイコン![info.png](https://qiita-image-store.s3.amazonaws.com/0/82090/fdfe296e-64c9-2070-05a6-bead94ae23c7.png)が表示されています。
その情報アイコンをクリックすると、そのサイトの接続状態の説明が吹き出しで表示されます。
より詳しい内容を確認するには詳細をクリックします。
![ssl-icon-check1.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9a0d65a1-1a8d-6824-c89c-c826e2aea437.png)

すると以下のような画面が表示されます。**「Mixed Content」**となっていて説明にも**「This site includes HTTP resources」**となっているので、どうやらこのページ内に**http://**でリンクが貼られている部分があるみたいです。
![ssl-icon-check2.png](https://qiita-image-store.s3.amazonaws.com/0/82090/b9f901fd-0f19-3dfe-d05b-e730d7239df8.png)

では、実際にそれはどこになるのでしょうか？それを確認するにはこの状態で更新をしてみましょう。
すると中央の部分にさっきとは違って色々URLがリストされます。ここの**Non-Secure Origins**にリストされているのが**http://**でリンクを貼っている部分、**Secure Origin**にリストされているのが**https://**でリンクを貼っている部分になります。
![ssl-icon-check3.png](https://qiita-image-store.s3.amazonaws.com/0/82090/411707b7-3fd9-4603-d0ec-9c5c9cd02aa8.png)

本来であればここで**http://**の部分を**https://**へ修正してあげるべきなのですが、必ずしもそのリンク先が**https://**に対応しているサイトであるとは限りません。今回は対応していなかったのでこのままにしました。


<br>
# おわりに
最近ではデフォルトでSSLを導入しているサイトが増えてきましたが、サイト内のリンクにも注意する必要があります。そこでChromeはそこらへんもデフォルトでアイコン表示してくれるのですぐ気がつくし、対応必要箇所が簡単に確認できるなと感じました。
ただ、今回みたいに回避不能な場合はちょっと辛いですね。。。

