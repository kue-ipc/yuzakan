# ユーザー管理システム Yuzakan (ゆざかん)

システムは**作成中です**

「ゆざかん」はお湯とザクロが入った缶です。

このプロジェクトは花見をしながら作成されています。

## TODO

* 機能
    * [ ] 利用者
        * [x] ログイン
        * [x] パスワード変更
        * [ ] G Suite 利用登録
        * [ ] Office 365 利用登録
        * [ ] メール転送設定
        * [ ] 情報確認(自分のみ)
        * [ ] ユーザー検索
    * [ ] 管理者
        * [ ] ログイン
        * [ ] 全体設定
        * [ ] プロバイダー管理
        * [ ] 強制パスワード変更
        * [ ] G Suite 連携
            * [ ] ユーザー管理
            * [ ] 所属管理
        * [ ] Office 365 連携
            * [ ] ユーザー管理
        * [ ] ユーザー管理
            * [ ] ユーザー登録
            * [ ] ユーザー変更
            * [ ] ユーザー削除
        * [ ] ユーザー検索
* 接続(アダプター)
    * [ ] ローカル
    * [ ] LDAP
    * [ ] AD
    * [ ] SSH
    * [ ] Ansible
    * [ ] G Suite
    * [ ] Office 365

---

ここから下はまだちゃんと書いていない。

## 動作環境

プログラミング言語

* Ruby 2.5.x以上 (2.6.x以上推奨)
* Node.js 8.x以上 (12.x以上推奨) ※

※ assetsをコンパイル済みであれば不要

データベース

* SQLite (本番環境では非推奨)
* MariaDB
* PostgreSQL

サポートする予定のOS/ディストリビューション

* Ubuntu 18.04LTS
* CentOS 8

## Setup


```
$ bundle insntall
```

How to run tests:

```
% bundle exec rake
```

How to run the development console:

```
% bundle exec hanami console
```

How to run the development server:

```
% bundle exec hanami server
```

How to prepare (create and migrate) DB for `development` and `test` environments:

```
% bundle exec hanami db prepare

% HANAMI_ENV=test bundle exec hanami db prepare
```

Explore Hanami [guides](http://hanamirb.org/guides/), [API docs](http://docs.hanamirb.org/1.3.1/), or jump in [chat](http://chat.hanamirb.org) for help. Enjoy! 🌸
