# frozen_string_literal: true

RSpec.describe Utanone::Uta do
  let(:uta) { Utanone::Uta.new(str) }
  let(:str) { 'あっつい夏の日、3時にアイスクリームを食べちゃったね' }

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
end
