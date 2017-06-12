---
title: ADアカウントユーザにデフォルトでローカルユーザの管理権限を設定する方法。
date: 2017-06-12
tags: ActiveDirectory,
author: ayako
ogp:
  og:
    description: ''
---

以前ご紹介した、ADアカウントにローカル管理権限を設定する方法について新たなことがわかったので、情報更新です。

[[ActiveDirectory]ADアカウントユーザにデフォルトでローカルユーザの管理権限を設定する方法](https://blog.proudit.jp/2017/05/22/AD-Administrator.html)


#前回のさらっとまとめ

前回の記事では、ADアカウントが初回ログイン時からデフォルトでローカルの管理権限をもつ、すなわちAdministratorsに所属するように設定する方法をご紹介していました。

例)DomainUsersをAdministratorsに所属させる。<br>
[制限されたグループ]の設定では、以下２パターンの設定方法があります。
<br>
①<br>
Administratorsのメンバーシップ構成に**このグループのメンバー**として、DomainUsersを追加する方法
![GPO06.png](https://qiita-image-store.s3.amazonaws.com/0/174392/59a0c6fb-9d5c-e642-170c-78dd6c0ca2cf.png)


②<br>
DmainUsersのメンバーシップ構成に**このグループの所属**として、Administratorsを追加する方法
![GPO07.png](https://qiita-image-store.s3.amazonaws.com/0/174392/207fc68a-3296-cee0-0b90-3ae528b92b42.png)

前回アップした記事では①、②両方向からメンバーへ所属させる方法をとっていました。<br>
が、その後調べているとドメイン参加後のローカルAdministratorsグループをどのようにしたいか、によって設定の仕方が異なることがわかりました。

#指定したユーザのみ権限を与える　or　指定したユーザ+もとのユーザにも権限を残す

①
Administratorsのメンバーシップ構成に**このグループのメンバー**として、DomainUsersを追加する方法
![指定のユーザだけに権限を与える.png](https://qiita-image-store.s3.amazonaws.com/0/174392/cc1d859c-5411-dc94-4606-da6a7c82fdd7.png)

上記の設定を行った場合、
ここで設定したユーザのみ、このキャプチャでいうDomainUsersと黒塗りしているグループの２つのグループのユーザだけに管理権限が与えられる。<br>
そのため、もともとAdministratorsに所属していたメンバーは全て権限から外れてしまいます。<br>
ただしAdministratorの管理権限はそのまま残ります。

![パターン1.png](https://qiita-image-store.s3.amazonaws.com/0/174392/5bee2fb9-c2b4-5501-92ab-d37f10c646a7.png)

ローカルでAdministratorsに所属していたメンバーは除外されてしまいました。
<br>

②<br>
DmainUsersのメンバーシップ構成に**このグループの所属**として、Administratorsを追加する方法
![指定したユーザも追加する.png](https://qiita-image-store.s3.amazonaws.com/0/174392/4855b1cc-43c2-0d9b-a942-5e710e025cef.png)
こちらの場合は、DomainUesrsの他にもともと設定されていたローカルユーザはそのまま残ります。<br>
DomainUsersが新たに追加される状態です。

ローカルのAdministratorsのグループ構成を確認してみます。

![パターン２.png](https://qiita-image-store.s3.amazonaws.com/0/174392/172dce8d-e59d-348d-3db0-d16a57743191.png)

既存ユーザと新たに追加したドメインユーザグループの両方がAdministratorsに入っています。

#想定する利用方法に応じて使い分けが必要

ADユーザに対してデフォルトでローカルの管理権限を追加する方法は①もしくは②どちらの方法でも実現可能ですが、
ローカルユーザの管理権限をどうするのか？<br>
によって設定の仕方が変わってきます。

ローカルユーザに管理権限を残すか残さないか、今一度確認の上設定を行うことをおすすめします。<br>

ちなみに前回の記事で両方向から設定を行った際は、既存のローカルユーザの権限はなくなってしまいました。<br>
おそらく①で設定した内容が優先して？反映されていた、ということになります。
<br>
今回はローカルユーザの権限を残す形でドメインユーザグループの追加を行いたかったので、パターン②の方法で設定を修正しました。



