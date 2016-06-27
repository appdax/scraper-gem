RSpec.describe AppDax::MultiPartial do
  let(:partial) { described_class.new data, AppDax::Partial }

  before do
    allow_any_instance_of(AppDax::Partial).to receive(:available?)
      .and_return(true)
  end

  describe '#available?' do
    subject { partial.available? }

    context 'when having one item' do
      let(:data) { [{}] }
      it { is_expected.to be_truthy }
    end

    context 'when being empty' do
      let(:data) { [] }
      it { is_expected.to be_falsy }
    end
  end

  describe '#[]' do
    let(:data) { [] }
    subject { partial[:data] }
    it { is_expected.to be_a(Array) }
  end

  describe '#exec' do
    let(:data) { [{}] }
    subject { partial.exec { available? } }
    it { is_expected.to be_a(Array) }
  end
end
