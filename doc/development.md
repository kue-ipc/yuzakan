# 開発環境メモ

DBのユーザー名とパスワード

ユーザー名: yuzakan
パスワード: pass+yuzakan42

DBをCREATE/DROPできるように全権限を与える。
```
GRANT ALL ON *.* TO 'yuzakan'@'localhost' IDENTIFIED BY 'pass+yuzakan42';
```

## テスト用のローカルユーザー追加

local_provider = ProviderRepository.new.find_with_adapter_by_name('local')
('01'..'99').each { |n| local_provider.create("lu#{n}", 'pass', display_name: "ローカル#{n}") }
user_repository = UserRepository.new
('02'..'99').each { |n| user_repository.create({name: "lu#{n}", display_name: "ローカル#{n}"}) }
