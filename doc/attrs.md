# 属性

## 属性の補完

operations.complete_attrsを用いて補完を行う。

### 入力

user
    name: string
    primary_group: group
    groups: group[]
    affilitaion: affilitaion
    attrs: {}
group
    name: string
    affilitaion: affiliation
    attrs: {}
affilitaion
    name: string
    attrs: {}

associateされた情報は一段階のみで、二段階目は読まない。つまり、attrsを除いて、

### ルール

attr_repoからカテゴリー別に属性の一覧を取得し、order順に処理する。

- attrがreadonlyの場合: 入力値を返す。
- attrがforcedの場合: codeで計算した値を返す。
- 入力値が存在し、かつ、nilではない: 入力値を返す。
- 入力値が存在しない、または、nilである: codeで計算した値を返す。

### codeでの計算

codeが空の場合はnilを返す。codeでの入力で、attrsのみ、ルールで変換中のattrsを使う。それ以外は、入力の値を使う。codeでの出力をattrで指定された型に変換して返す。

## codeの書き方

codeはHandlebarsを用いる。
<https://handlebarsjs.com/>
これは、RubyとJavaScript双方で使用できるようにするためである。

各パラメーターにはそのままアクセスできる。

```hbs
{{name}}
{{attrs.display_name_ja}}
{{affiliation.name}}
{{affiliation.attrs.label}}
{{#with primary_group}}{{name}} {{attrs.description}}{{/with}}
{{#each groups}}{{#unless @first}},{{/unless}}{{name}}{{/each}}
```

デフォルトのHandlebarsとは異なり、HTMLエスケープはされないため、`{{{...}}}`と三重にする必要はない。

関数を用いる場合は次のようにする。

```hbs
{{upcase name}}
{{upcase 5 (first_word attrs.display_name_ja)}}
```

### 使用可能な関数

全ては文字列として扱われることに注意すること。

- upcase _var_ ... 全て大文字にする。
- downcase _var_ ... 全て小文字にする。
- slice _start_ _end_ _var_ ... start番目からend番目までの文字を切り出す。end番目は含まない。サロゲートペアは考慮するが文字結合は考慮しない。endが`undefined`または`null`の場合は最後まで取り出す。
- first_word _var_ ... 空白区切りした最初の文字列。空白はWhite_Spaceプロパティであるかどうかで判別する。
- last_word _var_... 空白区切りした最後の文字列。空白はWhite_Spaceプロパティであるかどうかで判別する。
- digest "_algo_" _var_ ... 指定のアルゴリズムでハッシュ(メッセージダイジェスト)を作る。
    - md5
    - sha1
    - sha256
    - sha384
    - sha512
    - xxh32
    - xxh64
    - xxh3
    - xxh128
- dict "_dict_" _var_ ... 指定の辞書を引く。該当する名前がない場合は空文字列になる。

first_wordとlast_wordは/\p{White_Space}/uで区切りを行う。
