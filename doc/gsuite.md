# Google Workspace アダプター 設定

参考文献

* https://developers.google.com/admin-sdk/directory/v1/quickstart/ruby?hl=ja
* https://github.com/googleapis/google-api-ruby-client/blob/master/docs/oauth-server.md

Google Workspace アダプターを利用するにはサービスアカウントが必要になる。
サービスアカウントを作成する一連の手順を説明する。

## プロジェクトの作成

1. Google Cloud Platform にGoogle Workspaceの管理者でログイン
    https://console.cloud.google.com/
2. 「IAMと管理」の「リソースの管理」
    https://console.cloud.google.com/cloud-resource-manager
3. 「プロジェクトを作成」
    プロジェクト名: Yuzakan
    プロジェクト ID: yuzakan-(ランダムな数値) (回転マークをクリック)
    組織: Google Workspaceのドメイン
    場所: Google Workspaceのドメイン

反映されるまで数分必要

## サービスアカウント

1. 「IAMと管理」の「サービスアカウント」
    https://console.developers.google.com/iam-admin/serviceaccounts
2. 作成したサービスを選択
3. 「サービスアカウントを作成」
    サービスアカウント名: app
    サービスアカウント ID: app-(ランダムな数値)
    (あとのオプションは選ばない)
4. 編集で「Google Workspace ドメイン全体の委任を有効にする」にチェック
    同意画面のプロダクト名: ユーザー管理
    (設定できるようになるまで、暫く掛かる場合がある)
5. 編集で「鍵を追加」から「新しい鍵を作成」で鍵を作成
    キーのタイプはJSONにすること。

## API

1. 「APIとサービス」のダッシュボード
2. 有効なAPI選んですべて無効にする。
3. 「ライブラリ」で「Admin SDK」だけを有効にする。

## サービスアカウントの権限

1. Google Admin
    https://admin.google.com
2. セキュリティ→APIの制御
3. ドメイン全体の委任
4. 「新しく追加」
    クライアントID: サービスアカウントのクライアントID(数字のみのID)
    スコープ:
    * https://www.googleapis.com/auth/admin.directory.user
    * https://www.googleapis.com/auth/admin.directory.group
    * https://www.googleapis.com/auth/admin.directory.user.security
