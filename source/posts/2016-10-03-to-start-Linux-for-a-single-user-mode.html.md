---
title: Linuxをシングルユーザーモードで起動する
date: 2016-10-03
tags: Linux
author: kohei
ogp:
  og: 'シングルユーザーモードで起動すると必要最小限のデーモンを起動し、パスワードを入力することなく、rootアカウントでログインするモー>ドになります。
Windowsのセーフモードに当たるもので、主にメンテナンスの際に利用されます。'
---

# はじめに
シングルユーザーモードで起動すると必要最小限のデーモンを起動し、パスワードを入力することなく、rootアカウントでログインするモードになります。
Windowsのセーフモードに当たるもので、主にメンテナンスの際に利用されます。

# 起動
1. まずサーバーを起動します。
<br>

2. 「Press any key to enter the menu」という画面が表示されたら「ESC」キーを押下します。
![linux_single01.png](https://qiita-image-store.s3.amazonaws.com/0/82090/34016692-57c8-5a73-a951-6806b8724c02.png)
<br>

3. 「CentOS ・・・」と表示されるので、「e」キーを押下します。
もし、複数カーネルが表示された場合は起動時に利用しているカーネルを指定してください。
![linux_single02.png](https://qiita-image-store.s3.amazonaws.com/0/82090/1a620046-126b-1bfb-b86f-e131ea189130.png)
<br>

4. 「kernel ・・・」のところで「e」キーを押下します。
![linux_single03.png](https://qiita-image-store.s3.amazonaws.com/0/82090/6e60a545-4fbe-3b62-0df4-bbe203188c17.png)
<br>

5. 行の末尾に「single」を入力して「Enter」キーを押下します。
![linux_single05.png](https://qiita-image-store.s3.amazonaws.com/0/82090/95510eca-6cdd-9cf4-3cff-511874bf37c5.png)
<br>

6. 「b」キーを押下します。
![linux_single06.png](https://qiita-image-store.s3.amazonaws.com/0/82090/039fad85-935c-726e-71d2-56ff731b3199.png)
<br>

7. あとは起動してプロンプトが返ってきたら終わりです。
![linux_single07.png](https://qiita-image-store.s3.amazonaws.com/0/82090/9ba0ac99-7e5d-fa8f-926a-4176efc56ad1.png)


# おわりに
最近ではAWSなどのクラウドの普及によって物理サーバーに触れる機会がほとんどないと思いますが、ここら辺は一応基本知識なので、インフラエンジニアは知っておいた方がいざという時に恥をかかないで済むかもしれません。
