RSpec.describe AppDax::Stock do
  describe 'basic properties' do
    let(:methods) { %w(name wkn isin branch sector country symbol currency) }
    let(:stock) { described_class.new(nil) }

    it { expect(stock).to respond_to(*methods) }
    it('should return nil by default') do
      methods.each { |method| expect(stock.public_send(method)).to be_nil }
    end
  end

  describe '::id' do
    subject { described_class.id }
    after { described_class.id :isin }
    it('should be :isin by default') { is_expected.to be(:isin) }

    context 'when assigning an valid value' do
      before { described_class.id :wkn }
      it('should accept it') { is_expected.to be(:wkn) }
    end

    context 'when assigning an invalid value' do
      it('should not accept it') do
        expect { described_class.id :name }.to raise_error(ArgumentError)
      end
    end
  end

  describe '#available?' do
    let(:stock) { described_class.new(data) }
    subject { stock.available? }
    before { allow(stock).to receive(:isin).and_return isin }

    context 'when data is present' do
      let(:data) { {} }

      context 'and ISIN is present' do
        let(:isin) { 123 }
        it { is_expected.to be_truthy }
      end

      context 'but ISIN is not present' do
        let(:isin) { nil }
        it { is_expected.to be_falsy }
      end
    end

    context 'when data is not present' do
      let(:data) { nil }

      context 'and ISIN is present' do
        let(:isin) { 123 }
        it { is_expected.to be_falsy }
      end

      context 'but ISIN is not present' do
        let(:isin) { nil }
        it { is_expected.to be_falsy }
      end
    end
  end
end
