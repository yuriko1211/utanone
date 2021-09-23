require 'natto'
module Utanone
  class Uta
    attr_reader :original_str, :parsed_str

    EXCLUDING_COUNTING_RUBY_BY_TANKA = /ァ|ィ|ォ|ャ|ュ|ョ/
    EXCLUDING_COUNTING_LEXICAL_CATEGORIES = %w(記号)

    def initialize(str)
      @original_str = str
      @parsed_str = parse_to_hash(str)
    end

    def yomigana
      @parsed_str.map { _1[:ruby] }.join
    end

    def count(tanka: false)
      words_hash_without_symbol = @parsed_str.reject{ Utanone::Uta::EXCLUDING_COUNTING_LEXICAL_CATEGORIES.include?(_1[:lexical_category]) }
      count_size = 0
      words_hash_without_symbol.each do |h|
        if tanka
          # tanka オプションを入れた場合は ァ|ィ|ォ|ャ|ュ|ョ は音数に数えない
          count_size += h[:ruby].size - h[:ruby].scan(Utanone::Uta::EXCLUDING_COUNTING_RUBY_BY_TANKA).size
        else
          count_size += h[:ruby].size
        end
      end
      count_size
    end

    private
    def parse_to_hash(str)
      begin
        parsed_str_enum = natto.enum_parse(conversion_number(str))
      rescue Natto::MeCabError => e
        raise Utanone::ParseError
      end

      parsed_str_enum.each_with_object([]) do |result, array|
        next if result.is_eos?
        # 形態素
        word = result.surface
        splited_result = result.feature.split(/\t|,/)
        # 品詞
        lexical_category = splited_result[0]
        # 読み
        ruby = splited_result[7]

        raise Utanone::ParseError unless ruby

        array << {
          word: word,
          ruby: ruby,
          lexical_category: lexical_category,
          ruby_size: ruby.size
        }
      end
    end

    def conversion_number(str)
      # 半角数字を全角数字にしないと読みが取れないので変換する
      original_str.tr("0-9a-zA-Z", "０-９ａ-ｚＡ-Ｚ")
    end

    def natto
      @natto ||= Natto::MeCab.new
    end
  end
end
