# 開発環境メモ

DBのユーザー名とパスワード

ユーザー名: yuzakan
パスワード: pass+yuzakan42

DBをCREATE/DROPできるように全権限を与える。
```
GRANT ALL ON *.* TO 'yuzakan'@'localhost' IDENTIFIED BY 'pass+yuzakan42';
```
