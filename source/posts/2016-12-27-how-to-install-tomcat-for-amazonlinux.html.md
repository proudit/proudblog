---
title: Amazon Linuxにtomcat 5.5をインストールする。
date: 2016-12-27
tags: AWS, Java, Tomcat
author: kohei
ogp:
  og: 'Amazon Linuxにtomcat 5.5をインストールしました。'
---

# はじめに
Amazon Linuxにtomcat 5.5をインストールしました。

#### **構成**

| OS/MW        | version  |
| :---         | :--      |
| Amazon Linux | 2016.09  |
| java         | 1.5.0_22 |
| tomcat       | 5.5.36   |


<br>
# javaのインストール
まずはjavaのインストールからです。ただ、今回のAmazon Linuxでは既に異なるバージョンのjavaがインストールされているため、まずアンインストールを行なったのちに今回指定のjavaをインストールを行います。

<br>
##### **・既存のjdkバージョンの確認**
`yum list installed`で既にインストールされているパッケージを確認することができます。

```bash:
$ yum list installed |grep -i java
java-1.7.0-openjdk.x86_64                 1:1.7.0.121-2.6.8.1.69.amzn1 installed
javapackages-tools.noarch                 0.9.1-1.5.amzn1              installed
tzdata-java.noarch                        2016j-1.67.amzn1             installed

$ yum list installed |grep -i jdk
java-1.7.0-openjdk.x86_64                 1:1.7.0.121-2.6.8.1.69.amzn1 installed
```


<br>
##### **・既存のjdkを削除**

```bash:
$ sudo yum remove java-1.7.0-openjdk
---
削除しました:
  java-1.7.0-openjdk.x86_64 1:1.7.0.121-2.6.8.1.69.amzn1                                                                                             

依存性の削除をしました:
  aws-apitools-as.noarch 0:1.0.61.6-1.0.amzn1      aws-apitools-common.noarch 0:1.1.0-1.9.amzn1     aws-apitools-ec2.noarch 0:1.7.3.0-1.0.amzn1    
  aws-apitools-elb.noarch 0:1.0.35.0-1.0.amzn1     aws-apitools-mon.noarch 0:1.0.20.0-1.0.amzn1 
```
依存関係の都合上、_aws-apitools_なども削除されてしまいます。


<br>
##### **・jdkの取得**
以下のサイトからダウンロードしてサーバへアップします。
[**Java SE 5.0 Downloads**](http://www.oracle.com/technetwork/java/javasebusiness/downloads/java-archive-downloads-javase5-419410.html#jdk-1.5.0_22-oth-JPR)
![java-se-development-kit5.png](https://qiita-image-store.s3.amazonaws.com/0/82090/56b6c23e-2c4e-975d-ccf8-5417ea2f1dbf.png)


<br>
##### **・jdkのインストール**
ダウンロードしてきたバイナリファイルに実行権限を付与してインストールします。

```bash:実行権限付与
$ chmod +x jdk-1_5_0_22-linux-amd64-rpm.bin
```

```bash:インストール
$ sudo ./jdk-1_5_0_22-linux-amd64-rpm.bin
```

同意するか聞かれるので_yes_を入力して_enter_を押下します。

```bash:同意
Do you agree to the above license terms? [yes or no] 
yes
Unpacking...
Checksumming...
0
0
Extracting...
UnZipSFX 5.50 of 17 February 2002, by Info-ZIP (Zip-Bugs@lists.wku.edu).
  inflating: jdk-1_5_0_22-linux-amd64.rpm  
準備しています...              ################################# [100%]
更新中 / インストール中...
   1:jdk-2000:1.5.0_22-fcs            ################################# [100%]
 
Done.
```
以上でjavaのインストールは完了しました。


<br>
# tomcatのインストール
tomcatは[Apache Archives](http://archive.apache.org)からダウンロードします。

```bash:ダウンロード
$ wget http://archive.apache.org/dist/tomcat/tomcat-5/v5.5.36/bin/apache-tomcat-5.5.36.tar.gz
--2016-12-27 02:27:48--  http://archive.apache.org/dist/tomcat/tomcat-5/v5.5.36/bin/apache-tomcat-5.5.36.tar.gz
archive.apache.org (archive.apache.org) をDNSに問いあわせています... 163.172.17.199
archive.apache.org (archive.apache.org)|163.172.17.199|:80 に接続しています... 接続しました。
HTTP による接続要求を送信しました、応答を待っています... 200 OK
長さ: 9665826 (9.2M) [application/x-gzip]
`apache-tomcat-5.5.36.tar.gz' に保存中

apache-tomcat-5.5.36.tar.gz           100%[======================================================================>]   9.22M   185KB/s    in 87s     

2016-12-27 02:29:15 (109 KB/s) - `apache-tomcat-5.5.36.tar.gz' へ保存完了 [9665826/9665826]
```

```bash:解凍
$ tar zxvf apache-tomcat-5.5.36.tar.gz 
```

```bash:配置
$ sudo mv apache-tomcat-5.5.36 /usr/local/
```


<br>
##### **・profileの設定**
tomcatの場合、ダウンロードしてきたのを配置した後、実行するのに必要な環境変数を設定する必要があります。

```bash:環境変数設定
$ sudo vim /etc/profile
export JAVA_HOME=/usr/java/jdk1.5.0_22
export TOMCAT_HOME=/usr/local/apache-tomcat-5.5.36
export CATALINA_HOME=/usr/local/apache-tomcat-5.5.36
export PATH=$PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin
export CLASSPATH=.:$JAVA_HOME/jre/lib:$JAVA_HOME/lib:$JAVA_HOME/lib/tools.jar:$CATALINA_HOME/common/lib
```

```bash:環境変数の読み込み
$ source /etc/profile
```

```bash:バージョン確認
$ java -version
java version "1.5.0_22"
Java(TM) 2 Runtime Environment, Standard Edition (build 1.5.0_22-b03)
Java HotSpot(TM) 64-Bit Server VM (build 1.5.0_22-b03, mixed mode)
```


<br>
##### **・tomcatの起動**
あとは起動して完了です。

```bash:tomcat起動
$ /usr/local/apache-tomcat-5.5.36/bin/catalina.sh start
Using CATALINA_BASE:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_HOME:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_TMPDIR: /usr/local/apache-tomcat-5.5.36/temp
Using JRE_HOME:        /usr/java/jdk1.5.0_22
Using CLASSPATH:       /usr/local/apache-tomcat-5.5.36/bin/bootstrap.jar
```

```bash:確認
$ ps aux |grep tomcat
ec2-user  2784 15.0 23.4 986200 118108 pts/0   Sl   02:33   0:03 /usr/java/jdk1.5.0_22/bin/java -Djava.util.logging.config.file=/usr/local/apache-tomcat-5.5.36/conf/logging.properties -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager -Djava.endorsed.dirs=/usr/local/apache-tomcat-5.5.36/common/endorsed -classpath /usr/local/apache-tomcat-5.5.36/bin/bootstrap.jar -Dcatalina.base=/usr/local/apache-tomcat-5.5.36 -Dcatalina.home=/usr/local/apache-tomcat-5.5.36 -Djava.io.tmpdir=/usr/local/apache-tomcat-5.5.36/temp org.apache.catalina.startup.Bootstrap start
ec2-user  2827  0.0  0.4 110472  2208 pts/0    S+   02:34   0:00 grep --color=auto tomcat
```

プロセスが起動しているのが確認できました。
また、ブラウザで_8080_へアクセスしてみるとtomcatのデフォルト画面が表示されます。

![tomcat.png](https://qiita-image-store.s3.amazonaws.com/0/82090/10952dd4-d24d-d7db-9831-49769e5a1950.png)


<br>
# tomcatの停止
一応、停止も行います。

```bash:停止
$ /usr/local/apache-tomcat-5.5.36/bin/catalina.sh stop
Using CATALINA_BASE:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_HOME:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_TMPDIR: /usr/local/apache-tomcat-5.5.36/temp
Using JRE_HOME:        /usr/java/jdk1.5.0_22
Using CLASSPATH:       /usr/local/apache-tomcat-5.5.36/bin/bootstrap.jar
```

<br>
# おわりに
tomcatの起動/停止は同じ`apache-tomcat-5.5.36/bin/`配下にある_starup.sh_と_shutdown.sh_でも可能です。
というかそっちで行うのが普通なんだと思います。

```bash:起動
$  /usr/local/apache-tomcat-5.5.36/bin/startup.sh 
Using CATALINA_BASE:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_HOME:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_TMPDIR: /usr/local/apache-tomcat-5.5.36/temp
Using JRE_HOME:        /usr/java/jdk1.5.0_22
Using CLASSPATH:       /usr/local/apache-tomcat-5.5.36/bin/bootstrap.jar
```

```bash:停止
$ /usr/local/apache-tomcat-5.5.36/bin/shutdown.sh 
Using CATALINA_BASE:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_HOME:   /usr/local/apache-tomcat-5.5.36
Using CATALINA_TMPDIR: /usr/local/apache-tomcat-5.5.36/temp
Using JRE_HOME:        /usr/java/jdk1.5.0_22
Using CLASSPATH:       /usr/local/apache-tomcat-5.5.36/bin/bootstrap.jar
```

