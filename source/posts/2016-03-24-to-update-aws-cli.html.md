---
title: aws-cliのバージョンをアップグレードする。for MacOS
date: 2016-03-24
tags: aws-cli, MacOS
author: kohei
---

気がつくとバージョンが上がっているaws-cliコマンド。
あまりにも頻繁に上がっているので、気が付いたら(向いたら？)バージョンアップを行うようにしています。
今回見たらバージョン1.10.6となっていました。とりあえず気が向いた(付いた？)のでアップグレードを行おうと思います。
ちなみにaws-cliのバージョンについては以下から確認できます。
https://github.com/aws/aws-cli

また、今回行っている環境はMac OS X El Capitainです。

<br>
# ①バージョンの確認

```bash:コマンド
$ aws --version
aws-cli/1.9.20 Python/2.7.10 Darwin/15.3.0 botocore/1.3.20
```

_aws-cli_のところを見ると_1.9.20_となっているのがわかります。
現時点(_2016-02-19_)での最新バージョンは_1.10.6_でした。
https://github.com/aws/aws-cli

<br>
# ②アップグレード

それではアップグレードを行いたいと思います。

```bash:コマンド
$ sudo pip install --upgrade awscli
Password:
〜 省略 〜
Collecting awscli
  Downloading awscli-1.10.6-py2.py3-none-any.whl (887kB)
    100% |████████████████████████████████| 888kB 627kB/s 
Requirement already up-to-date: rsa<=3.3.0,>=3.1.2 in /Library/Python/2.7/site-packages (from awscli)
Collecting s3transfer==0.0.1 (from awscli)
  Downloading s3transfer-0.0.1-py2.py3-none-any.whl
Requirement already up-to-date: colorama<=0.3.3,>=0.2.5 in /Library/Python/2.7/site-packages (from awscli)
Collecting botocore==1.3.28 (from awscli)
  Downloading botocore-1.3.28-py2.py3-none-any.whl (2.2MB)
    100% |████████████████████████████████| 2.2MB 253kB/s 
Requirement already up-to-date: docutils>=0.10 in /Library/Python/2.7/site-packages (from awscli)
Requirement already up-to-date: pyasn1>=0.1.3 in /Library/Python/2.7/site-packages (from rsa<=3.3.0,>=3.1.2->awscli)
Requirement already up-to-date: futures<4.0.0,>=2.2.0 in /Library/Python/2.7/site-packages (from s3transfer==0.0.1->awscli)
Requirement already up-to-date: jmespath<1.0.0,>=0.7.1 in /Library/Python/2.7/site-packages (from botocore==1.3.28->awscli)
Collecting python-dateutil<3.0.0,>=2.1 (from botocore==1.3.28->awscli)
  Downloading python_dateutil-2.4.2-py2.py3-none-any.whl (188kB)
    100% |████████████████████████████████| 192kB 2.4MB/s 
Collecting six>=1.5 (from python-dateutil<3.0.0,>=2.1->botocore==1.3.28->awscli)
  Downloading six-1.10.0-py2.py3-none-any.whl
Installing collected packages: six, python-dateutil, botocore, s3transfer, awscli
  Found existing installation: six 1.4.1
    DEPRECATION: Uninstalling a distutils installed project (six) has been deprecated and will be removed in a future version. This is due to the fact that uninstalling a distutils project will only partially uninstall the project.
    Uninstalling six-1.4.1:
Exception:
Traceback (most recent call last):
  File "/Library/Python/2.7/site-packages/pip/basecommand.py", line 209, in main
    status = self.run(options, args)
  File "/Library/Python/2.7/site-packages/pip/commands/install.py", line 317, in run
    prefix=options.prefix_path,
  File "/Library/Python/2.7/site-packages/pip/req/req_set.py", line 725, in install
    requirement.uninstall(auto_confirm=True)
  File "/Library/Python/2.7/site-packages/pip/req/req_install.py", line 752, in uninstall
    paths_to_remove.remove(auto_confirm)
  File "/Library/Python/2.7/site-packages/pip/req/req_uninstall.py", line 115, in remove
    renames(path, new_path)
  File "/Library/Python/2.7/site-packages/pip/utils/__init__.py", line 266, in renames
    shutil.move(old, new)
  File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/shutil.py", line 302, in move
    copy2(src, real_dst)
  File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/shutil.py", line 131, in copy2
    copystat(src, dst)
  File "/System/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/shutil.py", line 103, in copystat
    os.chflags(dst, st.st_flags)
OSError: [Errno 1] Operation not permitted: '/tmp/pip-l_kdbZ-uninstall/System/Library/Frameworks/Python.framework/Versions/2.7/Extras/lib/python/six-1.4.1-py2.7.egg-info'
```

なにやらエラーが発生。。。どうやらsix 1.4.1があることが原因らしい。

```bash:出力
  Found existing installation: six 1.4.1
    DEPRECATION: Uninstalling a distutils installed project (six) has been deprecated and will be removed in a future version. This is due to the fact that uninstalling a distutils project will only partially uninstall the project.
    Uninstalling six-1.4.1:
```

対応方法はいろいろありますが、今回はsixを無視してアップグレードする対応を行います。

```bash:コマンド
$ sudo pip install --upgrade awscli --ignore-installed six
〜 省略 〜
Collecting awscli
  Downloading awscli-1.10.6-py2.py3-none-any.whl (887kB)
    100% |████████████████████████████████| 888kB 657kB/s 
Collecting six
  Downloading six-1.10.0-py2.py3-none-any.whl
Collecting rsa<=3.3.0,>=3.1.2 (from awscli)
  Downloading rsa-3.3-py2.py3-none-any.whl (44kB)
    100% |████████████████████████████████| 45kB 7.0MB/s 
Collecting s3transfer==0.0.1 (from awscli)
  Downloading s3transfer-0.0.1-py2.py3-none-any.whl
Collecting colorama<=0.3.3,>=0.2.5 (from awscli)
  Downloading colorama-0.3.3.tar.gz
Collecting botocore==1.3.28 (from awscli)
  Downloading botocore-1.3.28-py2.py3-none-any.whl (2.2MB)
    100% |████████████████████████████████| 2.2MB 263kB/s 
Collecting docutils>=0.10 (from awscli)
  Downloading docutils-0.12.tar.gz (1.6MB)
    100% |████████████████████████████████| 1.6MB 365kB/s 
Collecting pyasn1>=0.1.3 (from rsa<=3.3.0,>=3.1.2->awscli)
  Downloading pyasn1-0.1.9-py2.py3-none-any.whl
Collecting futures<4.0.0,>=2.2.0 (from s3transfer==0.0.1->awscli)
  Downloading futures-3.0.5-py2-none-any.whl
Collecting jmespath<1.0.0,>=0.7.1 (from botocore==1.3.28->awscli)
  Downloading jmespath-0.9.0-py2.py3-none-any.whl
Collecting python-dateutil<3.0.0,>=2.1 (from botocore==1.3.28->awscli)
  Downloading python_dateutil-2.4.2-py2.py3-none-any.whl (188kB)
    100% |████████████████████████████████| 192kB 2.7MB/s 
Installing collected packages: pyasn1, rsa, futures, jmespath, six, python-dateutil, docutils, botocore, s3transfer, colorama, awscli
  Running setup.py install for docutils ... done
  Running setup.py install for colorama ... done
Successfully installed awscli-1.10.6 botocore-1.3.20 colorama-0.3.3 docutils-0.12 futures-3.0.5 jmespath-0.9.0 pyasn1-0.1.9 python-dateutil-1.5 rsa-3.3 s3transfer-0.0.1 six-1.4.1
```

無事アップグレードできました。
念のためawsコマンドでバージョンを表示します。

```bash:コマンド
$ aws --version
aws-cli/1.10.6 Python/2.7.10 Darwin/15.3.0 botocore/1.3.28
```

最新のバージョンになっているのが確認できました。

