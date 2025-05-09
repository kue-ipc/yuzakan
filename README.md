# ユーザー管理システム Yuzakan (ゆざかん)

システムは**作成中です**

「ゆざかん」はお湯とザクロが入った缶です。

このプロジェクトは花見をしながら作成されています。

## 互換性

* 同じマイナーバージョンでの互換性しかありません。

## 現在のレポジトリ

Hanami 2 へアップデート中です。

## 既知の不具合

* PostgreSQLでは、`psql -c '\list'`でデータベースの存在確認ができる環境でないと、`bundle exec hanami db drop` でデータベースが消えない。開発時にデータベースを再作成したい場合は、`dropdb yuzakan_development` と `dropdb yuzakan_test` で消すこと。

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

* Ruby >= 3.3
* Node.js >= 22

### データベース

* [x] PostgreSQL
* [ ] MariaDB
* [ ] SQLite

現在はPostgreSQLのみ対応しています。PostgreSQLに依存した方を使用しているため、他のDBのサポートについては未定です。

### セッション管理key-valueデータベース

* [x] redis (デフォルト)
* [ ] memcaced

reidsが無い場合は、クッキーセッション、オンメモリキャッシュを使用します。

### サポートするOS/ディストリビューション

* [x] Ubuntu 24.04 LTS
* [x] Rocky 9
* [ ] Rocky 10 (予定)

## セットアップ

### 本番環境

```sh
bundle insntall --deployment
npm install
bundle exec rake build
bundle exec hanami assets precompile
```

### 開発・テスト環境

```sh
bundle insntall
npm install
bundle exec rake build
```

テスト実施:

```sh
bundle exec rake
npm run test
```

開発コンソール起動:

```sh
bundle exec hanami console
```

開発サーバー起動:

```sh
bundle exec hanami server
```

`development`と`test`環境におけるDBの準備:

```sh
bundle exec rake cache:clean
bundle exec hanami db prepare
HANAMI_ENV=test bundle exec hanami db prepare
```

developmentではキャッシュを削除しておかないとseedが作られない時がある。

## 制限事項

### ユーザー名

最低限GoogleとMicrosoftの制限を満たすようにしてください。

* <https://support.google.com/a/answer/9193374>
* <https://support.microsoft.com/kb/2439357>

上記を踏まえて、次のように制限しています。

* 数字`[0-9]`、英小文字`[a-z]`、アンダーライン`_`、ハイフン`-`、ピリオド`.`のみ使用できる。
* 大文字小文字無視する。(全て小文字として扱う。)
* 最初の文字はハイフン、ピリオドは使用不可。(数字、英小文字とアンダーラインのみ使用可能。)
* 最後の文字はピリオドのみ使用不可。(英小文字、数字、アンダーライン、ハイフンは使用可能。)
* ピリオドは連続してはならない。

### パスワード

* ASCII印字可能文字(スペースを含むU+0020からU+007Eまで)が使用可能。
* bcryptは72文字までしか認識しない。
* CRYPT-DESは8文字までしか認識しない。
* LMハッシュは14文字までしか認識しない。
* PBKDF2は未実装。
