RSpec.describe Utanone::Uta do
  let(:uta) { Utanone::Uta.new(str) }
  let(:str) { 'あっつい夏の日、3時にアイスクリームを食べちゃったね' }

  describe 'initialize' do
    subject { Utanone::Uta.new(str) }

    context '正常にパースできたとき' do
      it 'インスタンスが生成される' do
        is_expected.to be_truthy
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

    context 'よみがなが訂正されている場合' do
      # MeCubによるよみがなは "ゴゼンヨンジノアカリ"
      let(:str) { '午前四時の灯' }
      let(:corrected_yomigana) { 'ゴゼンヨジノトモシビ' }

      it '訂正された読みが保存されること' do
        expect(subject.yomigana).to eq 'ゴゼンヨジノトモシビ'
        expect(subject.parsed_str).to eq [
          {:word=>"午前", :ruby=>"ゴゼン", :lexical_category=>"名詞", :ruby_size=>3},
          {:word=>"四", :ruby=>"ヨ", :lexical_category=>"名詞", :ruby_size=>1},
          {:word=>"時", :ruby=>"ジ", :lexical_category=>"名詞", :ruby_size=>1},
          {:word=>"の", :ruby=>"ノ", :lexical_category=>"助詞", :ruby_size=>1},
          {:word=>"灯", :ruby=>"トモシビ", :lexical_category=>"名詞", :ruby_size=>4}
        ]
      end
    end

    context 'よみがなが訂正されていない場合' do
      # MeCubによるよみがなは "ゴゼンヨンジノアカリ"
      let(:str) { '午前四時の灯' }
      let(:corrected_yomigana) { 'ゴゼンヨンジノアカリ' }

      it '元のUtaオブジェクトが返却されること' do
        expect(subject).to eq uta
      end
    end
  end
end
