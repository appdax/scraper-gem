RSpec.describe AppDax::Partial do
  let(:partial) { described_class.new data }

  describe '#available?' do
    subject { partial.available? }

    context 'when data is nil' do
      let(:data) { nil }
      it { is_expected.to be_falsy }
    end

    context 'when data is empty' do
      let(:data) { {} }
      it { is_expected.to be_falsy }
    end

    context 'when data is provided' do
      let(:data) { { k: 'v'} }
      it { is_expected.to be_truthy }
    end
  end

  describe '#age_in_days' do
    let(:data) { nil }
    subject { partial.age_in_days }
    before { allow(partial).to receive(:available?).and_return(availability) }

    context 'when available' do
      let(:availability) { true }
      it('should be 0 by default') { is_expected.to eq(0) }
    end

    context 'when not available' do
      let(:availability) { false }
      it { is_expected.to be_nil }
    end
  end

  describe '#[]' do
    let(:data) { {} }

    context 'when asking for valid method' do
      subject { partial[:data] }
      it('should redirect') { is_expected.to eq(data) }
    end

    context 'when asking for non valid method' do
      subject { partial[:xyz] }
      it { is_expected.to be_nil }
    end
  end

  describe '#validate_price' do
    let(:data) { nil }
    subject { partial.send :validate_price, price }

    context 'when price < 0' do
      let(:price) { -1 }
      it { is_expected.to be_nil }
    end

    context 'when price == 0' do
      let(:price) { 0 }
      it { is_expected.to be_nil }
    end

    context 'when price is 1 (> 0)' do
      let(:price) { 1 }
      it { is_expected.to eq(price) }
    end
  end

  describe '#prune' do
    before { allow(partial).to receive(:available?).and_return(availability) }

    context 'when not available' do
      let(:availability) { false }
      let(:data) { nil }
      subject { partial.send :prune, [1] }
      it { is_expected.to be_nil }
    end

    context 'when available' do
      let(:availability) { true }
      let(:data) { { key: :value } }

      context 'and array has only non-nil values' do
        subject { partial.send :prune, [1] }
        it { is_expected.to be_a(Array) }
        it { is_expected.to_not be_empty }
      end

      context 'and array has also nil values' do
        subject { partial.send(:prune, [1, nil, 2]) }
        it { is_expected.to be_a(Array) }
        it('should not prune array') { is_expected.to eq([1, nil, 2]) }
      end

      context 'and array contains only nil values' do
        subject { partial.send :prune, [nil] }
        it { is_expected.to be_nil }
      end

      context 'and array is empty' do
        subject { partial.send :prune, [] }
        it { is_expected.to be_nil }
      end

      context 'and hash contains only non-nil values' do
        subject { partial.send :prune, k: 'v' }
        it { is_expected.to_not be_nil }
      end

      context 'and hash contains also nil values' do
        subject { partial.send :prune, k1: 'v', nil => nil }
        it { is_expected.to_not include(nil) }
      end

      context 'and hash contains only nil values' do
        subject { partial.send :prune, k: nil }
        it { is_expected.to be_nil }
      end

      context 'and hash is empty' do
        subject { partial.send :prune, {} }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '#diff_in_days' do
    before { allow(partial).to receive(:available?).and_return(availability) }

    context 'when not available' do
      let(:availability) { false }
      let(:data) { nil }
      subject { partial.send :diff_in_days, 1 }
      it { is_expected.to be_nil }
    end

    context 'when available' do
      let(:availability) { true }
      let(:data) { { key: :value } }
      subject { partial.send :diff_in_days, date }

      context 'when passing nil' do
        let(:date) { nil }
        it { is_expected.to be_nil }
      end

      context 'when passing yesterday as a date' do
        let(:date) { Date.today - 1 }
        it { is_expected.to be(1) }
      end

      context 'when passing yesterday as a number' do
        let(:date) { (Date.today - 1).to_time.to_i }
        it { is_expected.to be(1) }
      end

      context 'when passing yesterday as a string' do
        let(:date) { (Date.today - 1).to_s }
        it { is_expected.to be(1) }
      end
    end
  end
end
