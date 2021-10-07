# ユーザー管理システム Yuzakan (ゆざかん)

システムは**作成中です**

「ゆざかん」はお湯とザクロが入った缶です。

このプロジェクトは花見をしながら作成されています。

## TODO

* 機能
    * [ ] 利用者
        * [x] ログイン
        * [x] パスワード変更
        * [x] Google Workspace 利用登録
        * [ ] Office 365 利用登録
        * [ ] メール転送設定
        * [x] 情報確認(自分のみ)
        * [ ] ユーザー検索
    * [ ] 管理者
        * [x] ログイン
        * [x] 全体設定
        * [x] プロバイダー管理
        * [ ] 強制パスワード変更
        * [ ] Google Workspace 連携
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
    * [x] Google Workspace
    * [ ] Office 365

## 動作環境

### プログラミング言語

* Ruby >= 2.6 < 3.0
* Node.js >= 12

Node.jsは必須です。

### データベース

* [ ] SQLite (本番環境では非推奨)
* [x] MariaDB
* [ ] PostgreSQL

現在はMariaDBのみテストしていますが、他DBもサポート予定です。

MariaDBはutf8mb4にしてください。DATABES_URLでは"?encoding=utf8mb4"を付ける必要があります。

### セッション管理key-valueデータベース

* [x] redis (デフォルト)
* [ ] memcaced (未テスト、キャッシュ機能は未実装)

### サポートするOS/ディストリビューション

* [x] Rocky Linux 8
* [x] Ubuntu 20.04 LTS
* [ ] CentOS 8
* [ ] CentOS Stream 8
* [ ] Ubuntu 22.04 LTS (予定)

現在はRocky Linux 8とUbuntu 20.04 LTSでのみテストしています。

## セットアップ

### 本番環境

```
$ bundle insntall --deployment
$ npm install
$ bundle exec rake build
$ bundle exec hanami assets precompile
```

### 開発・テスト環境

```
$ bundle insntall
$ npm install
$ bundle exec rake build
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

## 制限事項

### ユーザー名

最低限GoogleとMicrosoftの制限を満たすようにしてください。

* https://support.google.com/a/answer/9193374
* https://support.microsoft.com/kb/2439357

上記を踏まえて、次のように制限しています。

* 英小文字`[a-z]`、数字`[0-9]`、アンダーライン`_`、ハイフン`-`、ピリオド`.`のみ使用できる。
* 大文字小文字無視する。(全て小文字として扱う。)
* 最初の文字は数字、ハイフン、ピリオドは使用不可。(英小文字とアンダーラインのみ使用可能。)
* 最後の文字はピリオドのみ使用不可。(英小文字、数字、アンダーライン、ハイフンは使用可能。)
* ピリオドは連続してはならない。


