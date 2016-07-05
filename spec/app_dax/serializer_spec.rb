RSpec.describe AppDax::Serializer do
  let(:serializer) { described_class.new }

  describe '::feeds' do
    let(:feeds) { [Class.new(AppDax::Feed)] }

    it('should be empty by default') do
      expect(described_class.feeds).to be_empty
    end

    context 'when setting the feeds' do
      subject { described_class.feeds feeds }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when trying to assign invalid feed classes' do
      before { described_class.feeds Fixnum }
      subject { described_class.feeds }
      it('should not accept it') { is_expected.to_not include(Fixnum) }
    end

    context 'when getting the feeds' do
      before { described_class.feeds feeds }
      subject { described_class.feeds }
      it('should return it') { is_expected.to eq(feeds) }
      it('should return a copy') { is_expected.to_not be(feeds) }
    end
  end

  describe '::source' do
    let(:value) { :consors }

    it('should have no default value') do
      expect(described_class.source).to be_nil
    end

    context 'when setting a value' do
      subject { described_class.source value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when getting the value' do
      before { described_class.source value }
      subject { described_class.source }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '#feeds' do
    before { described_class.feeds Class.new(AppDax::Feed) }
    subject { serializer.feeds.first }
    it('should return instances') { is_expected.to be_a(AppDax::Feed) }
  end

  describe '#serialize' do
    context 'when no feeds are specified' do
      let(:stock) { AppDax::Stock.new(nil) }
      before { described_class.feeds [] }
      subject { serializer.serialize stock }
      it { is_expected.to be_nil }
    end

    context 'when feeds are specified' do
      let(:stock) { SpecStock.new(nil) }
      let!(:serializer) { SpecSerializer.new }
      subject { JSON.load serializer.serialize(stock), symbolize_names: true }

      it('should include mandatory keys') do
        is_expected.to include(*%w(id source created_at basic version feeds))
      end
    end
  end
end
