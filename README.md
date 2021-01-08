# ユーザー管理システム Yuzakan (ゆざかん)

システムは**作成中です**

「ゆざかん」はお湯とザクロが入った缶です。

このプロジェクトは花見をしながら作成されています。

## TODO

* 機能
    * [ ] 利用者
        * [x] ログイン
        * [x] パスワード変更
        * [x] G Suite 利用登録
        * [ ] Office 365 利用登録
        * [ ] メール転送設定
        * [x] 情報確認(自分のみ)
        * [ ] ユーザー検索
    * [ ] 管理者
        * [x] ログイン
        * [x] 全体設定
        * [x] プロバイダー管理
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
    * [x] ローカル
    * [x] LDAP
        * [ ] Posix NIS
        * [ ] Samba
        * [x] AD
    * [ ] SSH
    * [ ] Ansible
    * [x] G Suite
    * [ ] Office 365

## 動作環境

プログラミング言語

* Ruby >= 2.7 < 3.0
* Node.js >= 12

データベース

* SQLite (本番環境では非推奨)
* MariaDB
* PostgreSQL

サポートする予定のOS/ディストリビューション

* Ubuntu 20.04 LTS
* CentOS 8
* CentOS Stream 8
* Rocky Linux

## セットアップ

### 本番環境

```
$ bundle insntall --deployment
```

### 開発・テスト環境

```
$ bundle insntall
```

テスト実施:

```
$ bundle exec rake
```

開発コンソール起動:

```
$ bundle exec hanami console
```

開発サーバー起動:

```
$ bundle exec hanami server
```

`development`と`test`環境におけるDBの準備:

```
$ bundle exec hanami db prepare
$ HANAMI_ENV=test bundle exec hanami db prepare
```
