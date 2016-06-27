# See SpecFeed defined in spec/factories.rb
RSpec.describe SpecMultiFeed do
  describe '#generate' do
    let(:expected) do
      { items: [{ attr: 123, complex_attr: 'test' }],
        meta: {
          age: 0,
          meta_tag: 'meta_value',
          source: :source,
          feed: 'specmulti',
          multi: true
        } }
    end

    subject { described_class.new.generate SpecStock.new({}), :source }

    it('should convert the stock into a hash') do
      is_expected.to eq(expected)
    end
  end
end
