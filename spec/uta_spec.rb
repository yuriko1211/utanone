RSpec.describe Utanone::Uta do
  let(:uta) { Utanone::Uta.new(str) }
  let(:str) { 'あっつい夏の日、3時にアイスクリームを食べちゃったね' }

  describe 'initialize' do
    let(:str) { '一千年眠った明日を見てみたい太陽以外みな新しい' }

    context 'ref_utaが引数として渡されないとき' do
      subject { Utanone::Uta.new(str) }

      context '正常にパースできたとき' do
        it 'インスタンスが生成される' do
          is_expected.to be_truthy
        end

        it 'parsed_morphemes の値が期待通りであること' do
          expect(subject.parsed_morphemes).to eq [
            {:word=>"一", :ruby=>"イチ", :lexical_category=>"名詞"},
            {:word=>"千", :ruby=>"セン", :lexical_category=>"名詞"},
            {:word=>"年", :ruby=>"ネン", :lexical_category=>"名詞"},
            {:word=>"眠っ", :ruby=>"ネムッ", :lexical_category=>"動詞"},
            {:word=>"た", :ruby=>"タ", :lexical_category=>"助動詞"},
            {:word=>"明日", :ruby=>"アシタ", :lexical_category=>"名詞"},
            {:word=>"を", :ruby=>"ヲ", :lexical_category=>"助詞"},
            {:word=>"見", :ruby=>"ミ", :lexical_category=>"動詞"},
            {:word=>"て", :ruby=>"テ", :lexical_category=>"助詞"},
            {:word=>"み", :ruby=>"ミ", :lexical_category=>"動詞"},
            {:word=>"たい", :ruby=>"タイ", :lexical_category=>"助動詞"},
            {:word=>"太陽", :ruby=>"タイヨウ", :lexical_category=>"名詞"},
            {:word=>"以外", :ruby=>"イガイ", :lexical_category=>"名詞"},
            {:word=>"みな", :ruby=>"ミナ", :lexical_category=>"名詞"},
            {:word=>"新しい", :ruby=>"アタラシイ", :lexical_category=>"形容詞"}
          ]
        end
      end

      context 'Natto::MeCabError が発生したとき' do
        it 'Utanone::ParseError がraiseされる' do
          natto_mock = double('natto_mock')
          allow(natto_mock).to receive(:enum_parse).and_raise(Natto::MeCabError)
          allow(Natto::MeCab).to receive(:new).and_return(natto_mock)
          expect{ subject }.to raise_error(Utanone::ParseError)
        end
      end
    end

    context 'ref_utaが引数として渡されとき' do
      subject { Utanone::Uta.new(str, ref_uta) }

      # 読みの修正箇所
      # 1. "アシタ" => "アス"
      # 2. "イチ" => "イッ"
      let!(:ref_uta_original) { Utanone::Uta.new('明日のその先一千年後の星は瞬く') }
      let!(:ref_uta) { ref_uta_original.correct(corrected_yomigana: 'アスノソノサキイッセンネンゴノホシハマタタク')}

      context '正常にパースできたとき' do
        it 'インスタンスが生成される' do
          is_expected.to be_truthy
        end

        it 'parsed_morphemes の値が期待通りであること' do
          # 修正した下記の読みが適用されている
          # 1. "アシタ" => "アス"
          # 2. "イチ" => "イッ"
          expect(subject.parsed_morphemes).to eq [
            {:word=>"一", :ruby=>"イッ", :lexical_category=>"名詞"},
            {:word=>"千", :ruby=>"セン", :lexical_category=>"名詞"},
            {:word=>"年", :ruby=>"ネン", :lexical_category=>"名詞"},
            {:word=>"眠っ", :ruby=>"ネムッ", :lexical_category=>"動詞"},
            {:word=>"た", :ruby=>"タ", :lexical_category=>"助動詞"},
            {:word=>"明日", :ruby=>"アス", :lexical_category=>"名詞"},
            {:word=>"を", :ruby=>"ヲ", :lexical_category=>"助詞"},
            {:word=>"見", :ruby=>"ミ", :lexical_category=>"動詞"},
            {:word=>"て", :ruby=>"テ", :lexical_category=>"助詞"},
            {:word=>"み", :ruby=>"ミ", :lexical_category=>"動詞"},
            {:word=>"たい", :ruby=>"タイ", :lexical_category=>"助動詞"},
            {:word=>"太陽", :ruby=>"タイヨウ", :lexical_category=>"名詞"},
            {:word=>"以外", :ruby=>"イガイ", :lexical_category=>"名詞"},
            {:word=>"みな", :ruby=>"ミナ", :lexical_category=>"名詞"},
            {:word=>"新しい", :ruby=>"アタラシイ", :lexical_category=>"形容詞"}
          ]
        end
      end
    end

    # TODO: ルビが取得できなかったパターンのテストを追加したい
  end

  describe '#yomigana'do
    subject { uta.yomigana }

    it { is_expected.to eq 'アッツイナツノヒ、サンジニアイスクリームヲタベチャッタネ' }

    context '半角英数字が含まれるとき' do
      let(:str) { 'CDを夜3時に聞いた' }
      it { is_expected.to eq 'シーディーヲヨルサンジニキイタ' }
    end
  end

  describe '#count'do
    subject { uta.count(tanka: tanka_option) }

    context 'tankaがfalseのとき' do
      let(:tanka_option) { false }

      it 'よみがなの文字数から発音しない記号の文字数を引いた数をそのまま返す' do
        is_expected.to be 27
      end
    end

    context 'tankaがtrueのとき' do
      let(:tanka_option) { true }

      it 'よみがなの文字数から発音しない記号の文字数を引いた数に対してさらに「ァ|ィ|ォ|ャ|ュ|ョ」を除外した文字数を返す' do
        is_expected.to be 26
      end
    end
  end

  describe '#correct'do
    subject { uta.correct(corrected_yomigana: corrected_yomigana) }

    context 'よみがなが修正されている場合' do
      context '修正する形態素が連続していない場合' do
        # MeCubによるよみがなは "ゴゼンヨンジノアカリ"
        let(:str) { '午前四時の灯' }
        let(:corrected_yomigana) { 'ゴゼンヨジノトモシビ' }

        it 'よみがなが修正された状態のUtaオブジェクトが返却されること' do
          expect(subject.yomigana).to eq 'ゴゼンヨジノトモシビ'
          expect(subject.parsed_morphemes).to eq [
            {:word=>"午前", :ruby=>"ゴゼン", :lexical_category=>"名詞"},
            {:word=>"四", :ruby=>"ヨ", :lexical_category=>"名詞"},
            {:word=>"時", :ruby=>"ジ", :lexical_category=>"名詞"},
            {:word=>"の", :ruby=>"ノ", :lexical_category=>"助詞"},
            {:word=>"灯", :ruby=>"トモシビ", :lexical_category=>"名詞"}
          ]
        end

        it '元のUtaオブジェクトに変更がないこと' do
          subject
          expect(uta.yomigana).to eq 'ゴゼンヨンジノアカリ'
          expect(uta.parsed_morphemes).to eq [
            {:word=>"午前", :ruby=>"ゴゼン", :lexical_category=>"名詞"},
            {:word=>"四", :ruby=>"ヨン", :lexical_category=>"名詞"},
            {:word=>"時", :ruby=>"ジ", :lexical_category=>"名詞"},
            {:word=>"の", :ruby=>"ノ", :lexical_category=>"助詞"},
            {:word=>"灯", :ruby=>"アカリ", :lexical_category=>"名詞"}
          ]
        end
      end

      context '修正する形態素が連続している場合' do
        # MeCubによるよみがなは "ゴゼンヨンジノアカリ、アシタヨンジニシュウゴウネ"
        let(:str) { '午前四時の灯、明日四時に集合ね' }
        let(:corrected_yomigana) { 'ゴゼンヨジノトモシビ、アスヨジにシュウゴウネ' }

        it '修正する形態素が連続する部分のよみがなが修正されていない状態のUtaオブジェクトが返却されること' do
          expect(subject.yomigana).to eq 'ゴゼンヨジノトモシビ、アシタヨンジニシュウゴウネ'
          expect(subject.parsed_morphemes).to eq [
            {:word=>"午前", :ruby=>"ゴゼン", :lexical_category=>"名詞"},
            {:word=>"四", :ruby=>"ヨ", :lexical_category=>"名詞"},
            {:word=>"時", :ruby=>"ジ", :lexical_category=>"名詞"},
            {:word=>"の", :ruby=>"ノ", :lexical_category=>"助詞"},
            {:word=>"灯", :ruby=>"トモシビ", :lexical_category=>"名詞"},
            {:word=>"、", :ruby=>"、", :lexical_category=>"記号"},
            {:word=>"明日", :ruby=>"アシタ", :lexical_category=>"名詞"},
            {:word=>"四", :ruby=>"ヨン", :lexical_category=>"名詞"},
            {:word=>"時", :ruby=>"ジ", :lexical_category=>"名詞"},
            {:word=>"に", :ruby=>"ニ", :lexical_category=>"助詞"},
            {:word=>"集合", :ruby=>"シュウゴウ", :lexical_category=>"名詞"},
            {:word=>"ね", :ruby=>"ネ", :lexical_category=>"助詞"}
          ]
        end

        it '元のUtaオブジェクトに変更がないこと' do
          subject
          expect(uta.yomigana).to eq 'ゴゼンヨンジノアカリ、アシタヨンジニシュウゴウネ'
          expect(uta.parsed_morphemes).to eq [
            {:word=>"午前", :ruby=>"ゴゼン", :lexical_category=>"名詞"},
            {:word=>"四", :ruby=>"ヨン", :lexical_category=>"名詞"},
            {:word=>"時", :ruby=>"ジ", :lexical_category=>"名詞"},
            {:word=>"の", :ruby=>"ノ", :lexical_category=>"助詞"},
            {:word=>"灯", :ruby=>"アカリ", :lexical_category=>"名詞"},
            {:word=>"、", :ruby=>"、", :lexical_category=>"記号"},
            {:word=>"明日", :ruby=>"アシタ", :lexical_category=>"名詞"},
            {:word=>"四", :ruby=>"ヨン", :lexical_category=>"名詞"},
            {:word=>"時", :ruby=>"ジ", :lexical_category=>"名詞"},
            {:word=>"に", :ruby=>"ニ", :lexical_category=>"助詞"},
            {:word=>"集合", :ruby=>"シュウゴウ", :lexical_category=>"名詞"},
            {:word=>"ね", :ruby=>"ネ", :lexical_category=>"助詞"}
          ]
        end
      end
    end

    context 'よみがなが修正されていない場合' do
      # MeCubによるよみがなは "ゴゼンヨンジノアカリ"
      let(:str) { '午前四時の灯' }
      let(:corrected_yomigana) { 'ゴゼンヨンジノアカリ' }

      it '元のUtaオブジェクトが返却されること' do
        expect(subject).to eq uta
      end
    end
  end
end
