---
title: "middlemanをbuildしようとしたらエラーが出たのでその時の対応メモ。"
date: 2017-12-15
tags: middleman
author: kohei
ogp:
  og: ''
---

# はじめに
middlemanでbuildを行おうとしたら突然エラーで実行できなくなった。。。
最近、MacのOSをHigh Sierraにアップデートしたからそのせいっぽい。。。

あんまよくわからないけど、gonyogonyoいじったらbuildできるようになったのでその時の対応したことをまとめます。
余計なところもあったかもですがそこはご容赦くださいm(__)m

# 対応したこと
とりあえず以下のようにmiddleman buildしてエラーが出ました。

```bash:middleman(build)
$ bundle exec middleman build
/usr/local/bin/bundle: /System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/bin/ruby: bad interpreter: No such file or directory
```

OSもアップデートしたということもあり、とりあえず一旦updateかければ上手くいくかなと。

```bash:update
$ sudo gem update --system
Password:
Updating rubygems-update
Fetching: rubygems-update-2.7.2.gem (100%)
Successfully installed rubygems-update-2.7.2
Parsing documentation for rubygems-update-2.7.2
Installing ri documentation for rubygems-update-2.7.2
Installing darkfish documentation for rubygems-update-2.7.2
Done installing documentation for rubygems-update after 41 seconds
Parsing documentation for rubygems-update-2.7.2
Done installing documentation for rubygems-update after 0 seconds
Installing RubyGems 2.7.2
ERROR:  While executing gem ... (Errno::EPERM)
    Operation not permitted @ rb_sysopen - /System/Library/Frameworks/Ruby.framework/Versions/2.3/usr/bin/gem
```

なんかおこられてしまったので、調べてると以下のブログを発見。
[High Sierraでcocoapodsが使えなくなった時にやったこと](http://www.project-unknown.jp/entry/cocoapods-high-sierra)
というかここでもHigh Sierraにアップデートしたことが原因で動かなくなったと書いてあるので、やっぱりOSアップデートが原因みたいですね。

とりあえずパスを指定してもう一度update。

```bash:update
$ sudo gem update --system -n /usr/local/bin
Latest version already installed. Done.
```

middlemanもインストール。

```bash:middleman(install)
$ sudo gem install middleman -n /usr/local/bin
Done installing documentation for bundler, rack, tilt, erubis, fast_blank, parallel, servolux, dotenv, i18n, thread_safe, tzinfo, concurrent-ruby, activesupport, padrino-support, padrino-helpers, public_suffix, addressable, memoist, rb-fsevent, ffi, rb-inotify, listen, fastimage, sass, execjs, uglifier, contracts, hashie, hamster, backports, middleman-core, thor, middleman-cli, compass-import-once, temple, haml, coffee-script-source, coffee-script, kramdown, middleman after 70 seconds
40 gems installed
```

とりあえずもう一度実行。

```bash:middleman(build)
$ bundle exec middleman build
Could not find minitest-5.8.3 in any of the sources
Run `bundle install` to install missing gems.
```

bundleが無いと言われたのでもう一度bundlerインストール。

```bash:install(bundler)
$ sudo gem install bundler -n /usr/local/bin
Successfully installed bundler-1.16.0
Parsing documentation for bundler-1.16.0
Done installing documentation for bundler after 4 seconds
1 gem installed
```

再度buildを実行。

```bash:middleman(build)
$ bundle exec middleman build
Could not find minitest-5.8.3 in any of the sources
Run `bundle install` to install missing gems.
```

minitestが無いと怒られたのでインストール。

```bash:install(minitest)
$ sudo gem install minitest -n /usr/local/bin
Fetching: minitest-5.10.3.gem (100%)
Successfully installed minitest-5.10.3
Parsing documentation for minitest-5.10.3
Installing ri documentation for minitest-5.10.3
Done installing documentation for minitest after 0 seconds
1 gem installed
```

うーん。。。それでも変わらず。。。。

```bash:middleman(build)
$ bundle exec middleman build
Could not find minitest-5.8.3 in any of the sources
Run `bundle install` to install missing gems.
```

ということで、一旦bundleインストールしてみる。

```bash:bundle(install)
$ sudo bundle install --path /usr/local/bin
Don't run Bundler as root. Bundler can ask for sudo if it is needed, and installing your bundle as root will break this application for all non-root users on this
machine.
Fetching gem metadata from https://rails-assets.org/..
Fetching gem metadata from http://rubygems.org/..............
```

お、なにやら上手くいきそうな予感。

```bash:middleman(build)
$ bundle exec middleman build
   identical  build/stylesheets/reset.css
   identical  build/stylesheets/all.css
   identical  build/images/2017/0411_DelegatingDirectory/dd_04.png
```

無事build成功！


# おわりに
色々調べたところ以下の記事を見つけました。
[Apple、macOS High Sierra 1st BetaにRuby v2.3.3およびPHP v7.1.4をデフォルトで同梱。](https://applech2.com/archives/20170618-macos-10-13-high-sierra-update-ruby-and-php.html)
今回はOSアップデートにrubyも含まれてしまっていたのが原因だったということです。
おそらくMacを使い続ける限りこの先も同じことがありそうなのでこれは要チェックですね。

