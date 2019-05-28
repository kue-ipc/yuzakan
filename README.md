# Yuzakan

ユーザー管理システム Yuzakan(遊佐缶)

「ゆざかん」は山形県飽海郡遊佐町にあるという缶詰です。

このプロジェクトは花見をすることで作成されます。

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
