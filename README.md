# ユーザー管理システム Yuzakan (ゆざかん)

**作成中です**

「ゆざかん」は山形県飽海郡遊佐町にあるという缶詰です。

このプロジェクトは花見をしながら作成されています。

## TODO

- 機能
    - [ ] ログイン
    - [ ] パスワード変更
    - [ ] G Suite 連携
    - [ ] Office 365 連携
    - [ ] ユーザー登録・変更・削除
- 接続(アダプター)
    - [ ] ローカル
    - [ ] LDAP
    - [ ] AD
    - [ ] SSH
    - [ ] Ansible

---

ここから下はまだちゃんと書いていない。

## Setup



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
