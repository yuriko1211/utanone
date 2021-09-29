# Utanone

Utanone(歌の音) is a helper for creating tanka/haiku poems in Japanese.

形態素解析エンジンMeCabを使用して、入力した短歌/俳句の音数をカウントします。

## Requirements
- [MeCab 0.996](http://taku910.github.io/mecab/)
- Ruby 2.7 or greater

## Installation

```ruby
gem install utanone
```

## Usage
### MECAB_PATH の設定
`MECAB_PATH` を設定する必要があります。

```
ENV['MECAB_PATH']='/usr/local/lib/libmecab.so'
```

### Uta インスタンスの生成（ref_utaの指定なし）

```ruby
require 'utanone'

uta = Utanone::Uta.new('あっつい夏の日、3時にアイスクリームを食べちゃったね')
```

### #yomigana

よみがなを返します。
```ruby
uta.yomigana #=> "アッツイナツノヒ、サンジニアイスクリームヲタベチャッタネ"
```

### #count

文字数をカウントします。

```ruby
uta.count #=> 27
```

引数に `tanka: true` を渡すことで短歌、俳句での音数をカウントします。
（`ァ、ィ、ォ、ャ、ュ、ョ` は音数としてカウントしません。`ッ` は音数としてカウントします。）

```ruby
uta.count(tanka: true) #=> 26
```

### #correct
よみがなが形態素解析の結果と異なる場合によみがなを訂正できます。戻り値としてよみがなを訂正したUtaインスタンスを返却します。

```ruby
uta = Utanone::Uta.new('午前四時の灯')
uta.yomigana #=> ゴゼンヨンジノアカリ
corrected_uta = uta.correct(correct_yomigana: 'ゴゼンヨジノトモシビ')
corrected_uta.yomigana #=> ゴゼンヨジノトモシビ
```

### Uta インスタンスの生成（ref_utaの指定あり）
第2引数にref_utaを指定することで、ref_utaが保持しているよみがなを優先して、よみがなを設定します。

下記の例文では形態素解析の結果では「四」は「ヨ」、「灯」は「アカリ」とよみがなが設定されます。

よみがなをそれぞれ「ヨン」、「トモシビ」と修正したUtaインスタンスをref_utaとして第二引数に渡すことで、形態素として「四」「灯」が含まれる場合によみがなを「ヨン」、「トモシビ」として返却します。

```ruby
uta = Utanone::Uta.new('午前四時の灯')
uta.yomigana #=> "ゴゼンヨンジノアカリ"
ref_uta = uta.correct(correct_yomigana: 'ゴゼンヨジノトモシビ')
ref_uta.yomigana #=> "ゴゼンヨジノトモシビ"

uta2 = Utanone::Uta.new('灯が見える午前四時', ref_uta)
uta2.yomigana #=> "トモシビガミエルゴゼンヨジ"
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
