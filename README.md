# ユーザー管理システム Yuzakan (ゆざかん)

システムは**作成中です**

「ゆざかん」はお湯とザクロが入った缶です。

このプロジェクトは花見をしながら作成されています。

## 互換性

* 同じマイナーバージョンでの互換性しかありません。

## 現在のレポジトリ

Hanami 2 へアップデート中です。

## 既知の不具合

* PostgreSQLでは、`psql -c '\list'`でデータベースの存在確認ができる環境でないと、
    `bundle exec hanami db drop` でデータベースが消えません。
    実行時のユーザー名と同じ名前のデータベースを用意してください。

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

* [x] PostgreSQL >= 16
* [ ] MariaDB >= 10.11
* [ ] SQLite 3

現在はPostgreSQLのみ対応しています。
PostgreSQLに依存した型を使用しているため、他のDBのサポートについては未定です。

### セッション管理key-valueデータベース

* [x] valkey or redis >= 7
* [ ] memcaced

valkeyまたはreidsが無い場合は、クッキーセッション、オンメモリキャッシュを使用します。
memcachedは未テストです。

### サポートするOS/ディストリビューション

* [x] AlmaLinux 9 / Rocky 9 (with app streams)
* [ ] AlmaLinux 10 / Rocky 10 (予定)
* [x] Debian 12 / Ubuntu 24.04 LTS (with non-default Ruby and Node.js)
* [ ] Debian 13 / Ubuntu 26.04 LTS (予定)

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

* 数字`[0-9]`、英小文字`[a-z]`、アンダーライン`_`、ハイフン`-`、ピリオド`.`のみ使用できます。
* 大文字小文字無視します。(全て小文字として扱います。)
* 最初の文字はハイフン、ピリオドは使用できません。(数字、英小文字とアンダーラインのみ使用可能。)
* 最後の文字はピリオドのみ使用できません。(英小文字、数字、アンダーライン、ハイフンは使用可能。)
* ピリオドは連続させることはできません。

### パスワード

* ASCII印字可能文字(スペースを含むU+0020からU+007Eまで)が使用できます。
* bcryptは72文字までしか認識しません。
* CRYPT-DESは8文字までしか認識しません。
* LMハッシュは大文字小文字を無視して14文字までしか認識しません。
* PBKDF2は未実装です。

## 規約等

* 80/120列ソフトマージンルール
    <https://medium.com/@carlo.michaelis/the-80-120-column-soft-margin-rule-979526742197>
