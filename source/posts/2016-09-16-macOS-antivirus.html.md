---
title: Macにセキュリティソフトは必要か？
date: 2016-09-16
tags: セキュリティ対策,MacOS
author: ayako
ogp:
  og:
    description: ' セキュリティソフトが不要と言われてきたmac。本当にセキュリティ対策は不要なのか？もし使うならどんなソフトがあるのか。調べてみました！'
---

#はじめに　
---
Macユーザーになって約1年。
Mac=セキュリティソフト不要、ソフトが無くても大丈夫。と思っていました。
なぜMacにセキュリティソフトは不要といわれているのか？

**・Windowsと違い、Macユーザーは圧倒的に少ない**

Net Applicationsで発表された2016年6月のデスクトップOSシェア数をみてみると、Macのシェアは10％にも満たない。
シェアが少ないMacより、格段にシェアが多いwindowsを狙ったウィルスが多いのは必然的なこと。

![macos_antivirus](./2016/0916_Mac_AntiVirus/OSshere.png)

_引用元：http://news.mynavi.jp/news/2016/07/03/035/_

**・mac自体にセキュリティ機能が高い**

実際にMacに「セキュリティソフトは必要ありません」、
「Mac自体のセキュリティの更新とソフトの間で不具合が生じる可能性があるため、
インストールしない方がいい』という意見は多かったです。

とは言え、MACを標的にしたマルウェアが全くないわけではありません。

```
2015年になると、Macを狙ったマルウェアが大幅に増加しました。
以前から、MacはPCよりも安全だという都市伝説がありますが、単に標的になる機会が多いか少ないかという問題に過ぎません。
```
[引用元：Macを狙うマルウェアが急増！](http://ascii.jp/elem/000/001/152/1152209/)

やっぱりセキュリティ対策は必要です！

#Macに最適なセキュリティソフトとは（フリーソフト編）
---
今回は家庭向けで利用できるフリーソフトについて調べてみました。
フリーのセキュリティソフト自体選択肢があまりないようで、
どのサイトでも割と押しが強かったのが以下３つ。

・[Avira](https://www.avast.co.jp/mac)
・[Sophos](https://www.sophos.com/ja-jp/lp/sophos-home.aspx)
・[avast!](https://www.avast.co.jp/mac)

これを一つに絞ります！
ただ、どれも一長一短。
人それぞれ。使う環境によっても変わってくるのかもしれませんが、
絶対にこれが一番！なんてものはなさそうなので、
判断材料として以下の検証データを参考にしました。

[AV-TEST](https://www.av-test.org/en/news/news-single-view/12-security-suites-for-mac-os-x-put-to-the-test/)
_AV-TEST.orgとはセキュリティソフトの比較検証を行うドイツの独立系、最大手の検証機関。_

![macos_antivirus](./2016/0916_Mac_AntiVirus/AVTEST.png)


候補に挙げていた中ではavast、sophosが99.17%の検出率。
Aviraは99.33%でした。
ノーマークだったのですが、AVGはフリーながらも100%の検出率。

結果的にわたしが今回選んだのはavast!です。

avastは同サイト内での動作性評価があまり良くありませんでした、が、
法人向けに企業用アバスト、無償版が昨年提供されたということもあり、
一度試しに使ってみよう、というのが今回の最終的な決め手です。

#実際の使用感
---
インストールしてみて、、特にこれといって動作が重くなった感じはないです。
ちなみにインストール後に行ったフルスキャンは約1時間かかりました。

Macはセキュリティソフトはいらない、というユーザーは多いですが、
やはりウィルス感染は恐いです。
大切な情報が盗まれてしまったり、MACが使えなくなった、知らないうちに知人にウィルスをばらまいてしまっていた、そんな悲しい事態になる前に！セキュリティ対策しましょう！