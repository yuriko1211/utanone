require 'natto'
module Utanone
  class Uta
    attr_reader :original_str, :parsed_str

    # TODO: 半角数字だと読み仮名が出ないので全角数字にしてあげる処理をかませる必要がありそう
    def initialize(str)
      @original_str = str
      @parsed_str = parse_to_hash(str)
    end

    def parse_to_hash(str)
      natto = Natto::MeCab.new
      parsed_str_enum = natto.enum_parse(str)
      parsed_str_enum.each_with_object([]) do |result, array|
        next if result.is_eos?
        # 形態素
        word = result.surface
        splited_result = result.feature.split(/\t|,/)
        # 品詞
        lexical_category = splited_result[0]
        # 読み
        ruby = splited_result[7]

        array << {
          word: word,
          ruby: ruby,
          lexical_category: lexical_category,
          ruby_size: ruby.size
        }
      end
    end

    def yomigana
      @parsed_str.map { _1[:ruby] }.join
    end

    def count(tanka: false)
      words_hash_without_symbol = @parsed_str.reject{ _1[:lexical_category] == '記号' }
      count_size = 0
      words_hash_without_symbol.each do |h|
        if tanka
          # tanka オプションを入れた場合は ァ|ォ|ャ|ュ|ョ は音数に数えない
          count_size += h[:ruby].size - h[:ruby].scan(/ァ|ォ|ャ|ュ|ョ/).size
        else
          count_size += h[:ruby].size
        end
      end
      count_size
    end
  end
end
