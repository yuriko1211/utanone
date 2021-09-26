require 'natto'
module Utanone
  class Uta
    attr_reader :original_str, :parsed_morphemes

    EXCLUDING_COUNTING_RUBY_BY_TANKA = /ァ|ィ|ォ|ャ|ュ|ョ/
    EXCLUDING_COUNTING_LEXICAL_CATEGORIES = %w(記号)

    def initialize(str)
      @original_str = str
      @parsed_morphemes = parse_to_hash(str)
    end

    def yomigana
      @parsed_morphemes.map { _1[:ruby] }.join
    end

    def count(tanka: false)
      words_hash_without_symbol = @parsed_morphemes.reject{ Utanone::Uta::EXCLUDING_COUNTING_LEXICAL_CATEGORIES.include?(_1[:lexical_category]) }
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

    def correct(corrected_yomigana:)
      return self if yomigana == corrected_yomigana

      # 訂正したよみがなで再作成したUtaインスタンスを作成するので、一旦コピーする
      corrected_uta = Uta.new(self.original_str)

      corrected_uta.parsed_morphemes.each_with_index do |morpheme, i|
        # 形態素ごとによみがなの修正が必要であれば修正する
        if corrected_yomigana[0,morpheme[:ruby].size] == morpheme[:ruby]
          # よみがなが一致したらそのまま処理を続行する
          # 比較したよみがな部分は訂正済みよみがなから削除する
          corrected_yomigana.slice!(0, morpheme[:ruby].size)
          next
        else
          # よみがなが不一致なら修正する
          next_morpheme = corrected_uta.parsed_morphemes[i+1]
          if next_morpheme
            # 修正済みよみがなから次の形態素に一致する箇所を探すことで修正したい形態素のよみがなを取得する
            next_morpheme_start = corrected_yomigana.index(next_morpheme[:ruby])
            if next_morpheme_start
              # 取得できた場合は修正する
              morpheme[:ruby] = corrected_yomigana[0, next_morpheme_start]
            else
              # 一致箇所がなければ修正ができないものとして処理を中断する（よみがな不一致が連続すると修正できない）
              # TODO: 再帰を使って連続したよみがな不一致も修正できないか
              break
            end
            corrected_yomigana.slice!(0, morpheme[:ruby].size)
          else
            # 最後の形態素だった時
            morpheme[:ruby] = corrected_yomigana
          end
        end
      end
      corrected_uta
    end

    private
    def parse_to_hash(str)
      parsed_str_enum = natto.enum_parse(conversion_number(str))

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
          lexical_category: lexical_category
        }
      end
    rescue Natto::MeCabError => e
      raise Utanone::ParseError
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
