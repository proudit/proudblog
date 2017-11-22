---
title: AWSのメンテナンス EC2編
date: 2017-11-22
tags: AWS,
author: ayako
ogp:
  og:
    description: ''
---


#AWSからのメンテナンス通知
---

AWSからたまに送られてくる以下のような定期メンテナンス実施のアナウンスメール。

```
Dear Amazon EC2 Customer,

One or more of your Amazon EC2 instances is scheduled for maintenance on 2017-**-** for 2 hours starting at 2017-**-** 12:00:00 UTC UTC. During this time, the following instances in the ******* region will be unavailable and then rebooted:

************

Your instances will return to normal operations after maintenance is complete and all of your configuration settings will be retained. To continue normal operation and avoid any unavailability or reboots during this time, you can migrate the instances listed above to replacement instances. Replacement instances will not be affected by this scheduled maintenance. Otherwise, no action is required on your part.

以下省略
```

AWSではEC2群を頻繁にアップデートしており、多くのパッチやアップグレードの適用を行なっています。
今回も指定期間のうちにメンテナンスをするから、インスタンスが再起動されるよ。と言うお知らせでした。

再起動にかかる時間は通常、数分程度ですが少しでもサービスが止まってしまうと困る！と言う場合は指定のメンテナンス期間より前の任意の時間で再起動を行なってしまえばOKです。

#メンテナンス対象はコンソールからも確認可能
---

コンソール＞EC2＞左側のメニュー上部の[イベント]

![EC2メンテナンス01.png](https://qiita-image-store.s3.amazonaws.com/0/174392/3a2a4da8-330f-44eb-5ff8-9c20e721ba38.png)

現在予定されているメンテナンス対象が表示されます。

![EC2メンテナンス02.png](https://qiita-image-store.s3.amazonaws.com/0/174392/f622a8c7-5e50-7d51-5d58-1101e3f387d1.png)

予定の他に、進行中や完了ステータスになっているものも確認できます。
指定期間に実行されたインスタンスの状況も確認できるので安心です！

![EC2メンテナンス03.png](https://qiita-image-store.s3.amazonaws.com/0/174392/291e2d32-acb7-be8e-4ef0-fa3726d5fe93.png)


#システムリブートとインスタンスリブート
---

メンテナンスの内容によって、システムリブートとインスタンスリブート対応の仕方が少し異なります。
予定されたメンテナンスがどちらに該当するかはイベントの[イベントタイプ]から確認可能です。

システムリブートの場合は、stop　→　start
以下のように、インスタンスを完全に停止させてから開始します。

![EC2メンテナンス04.png](https://qiita-image-store.s3.amazonaws.com/0/174392/3974d412-02c1-5d3c-6c3f-e9a00c4bc0dd.png)

インスタンスリブートの場合は、再起動でOKです。
が、stop　→　startの対応しておけばより確実。

#おわりに
---

数分程度と言えど重要なサービスをのせたサーバのメンテナンス、あらかじめしっかりと対処が必要ですね。