# See SpecFeed defined in spec/factories.rb
RSpec.describe SpecFeed do
  describe '::feed_name' do
    subject { described_class.feed_name }
    it { is_expected.to eq('spec') }
  end

  describe '::kpis' do
    let(:kpis) { described_class.kpis }

    it('should return simple and complex kpis') do
      expect(kpis.keys).to eq([:simple, :complex])
    end

    context 'simple kpis' do
      subject { kpis[:simple].keys }
      it { is_expected.to eq([:my_partial]) }
    end

    context 'complex kpis' do
      subject { kpis[:complex].keys }
      it { is_expected.to eq([:complex_attr]) }
    end
  end

  describe '#generate' do
    let(:expected) do
      { attr: 123,
        complex_attr: 'test',
        meta: {
          age: 0,
          meta_tag: 'meta_value',
          source: :source,
          feed: 'spec'
        } }
    end

    subject { described_class.new.generate SpecStock.new({}), :source }

    it('should convert the stock into a hash') do
      is_expected.to eq(expected)
    end
  end
end
