---
title: ［ActiveDirectory運用］一般ユーザがドメイン参加させられるPCの台数制限について(1ユーザ10台)
date: 2017-04-11
tags: ActiveDirectory,
author: ayako
ogp:
  og:
    description: 'PCドメイン参加時の台数制限を回避する方法にチャレンジしてみました'
---

#PCドメイン参加時の台数制限
---
ADの運用を開始して、つまづくであろうポイントについて。
一般のユーザ権限でPCをドメイン参加させる際、台数制限があるのはご存知ですか？
一般ユーザの場合、1ユーザにつき10台までとなっています。

[【Active Directory】一般ユーザーがドメインに参加させられるPCの数は10台](https://blogs.technet.microsoft.com/junichia/2010/06/14/active-directorypc2596/)


台数制限は簡単に設定変更ができるので、制限をなくせばこの問題は簡単に解決です。

#制限数を変更する方法
---


ファイル名を指定して実行から［adsiedit.msc］を入力し、
ADSIエディターを起動します。

![dsadd](./2017/0411_DelegatingDirectory/dd_01.png)

プロパティを開いてms-DS-MachineAccountQuota属性の値を修正すればOKです。

![dsadd](./2017/0411_DelegatingDirectory/dd_02.png)

![dsadd](./2017/0411_DelegatingDirectory/dd_03.png)

#［制御の委任］コンピューターオブジェクトの作成権限を割り当てる
---

しかし、今回利用しているAmazon Directory Servise(MicrosoftAD)にはms-DS-MachineAccountQuota属性の変更ができないようです。
※公式のドキュメントで確認をしたわけではありませんが、実際の画面上にそのような項目はありませんでした。


というわけで別の策を講じます！

［制御の委任］という機能を使って、あるグループにコンピューターオブジェクトの作成権限を割り当てることにします。
グループは任意のもので構いません。

ユーザーとコンピューター　＞　対象のドメイン配下のUsersにカーソルを合わせ　＞　操作　＞　制御の委任

![dsadd](./2017/0411_DelegatingDirectory/dd_04.png)

オブジェクト制御の委任ウィザードが開始されます。

![dsadd](./2017/0411_DelegatingDirectory/dd_05.png)

追加したいユーザ、グループを選択し、次へ。

![dsadd](./2017/0411_DelegatingDirectory/dd_06.png)

委任するカスタムタスクを作成する　へチェック。

![dsadd](./2017/0411_DelegatingDirectory/dd_07.png)

フォルダ内の次のオブジェクトのみ　をチェックし、［コンピュータオブジェクト］をチェック。
選択するオブジェクトをこのフォルダに....の二箇所にもチェックを入れてください。

![dsadd](./2017/0411_DelegatingDirectory/dd_08.png)

［アクセス許可］
(全般)にすでにチェックが入っています。プロパティ固有にもチェックをいれ、読み取り、書き込みにチェックを入れます。

![dsadd](./2017/0411_DelegatingDirectory/dd_09.png)

完了です。
![dsadd](./2017/0411_DelegatingDirectory/dd_10.png)

追加した権限は対象グループのプロパティ　＞　セキュリティ情報から確認可能です。

![dsadd](./2017/0411_DelegatingDirectory/dd_11.png)

セキュリティ情報が表示されない場合は、表示　＞　拡張機能をチェックすると表示可能となります。

![dsadd](./2017/0411_DelegatingDirectory/dd_12.png)

#補足情報
---
既に前述していますが、今回の作業環境は［Amazon Directory Servise(MicrosoftAD)2008R2］です。
