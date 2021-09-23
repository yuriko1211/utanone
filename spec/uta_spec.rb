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

  end
end
