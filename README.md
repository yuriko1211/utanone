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

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

