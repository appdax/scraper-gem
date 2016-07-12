require 'fakefs/spec_helpers'

RSpec.describe AppDax::Scraper do
  describe '::fields' do
    let(:value) { [:f1, :f2] }

    it('should be empty by default') do
      expect(described_class.fields).to be_empty
    end

    context 'when setting a value' do
      subject { described_class.fields value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when getting the value' do
      before { described_class.fields value }
      subject { described_class.fields }
      it('should return it') { is_expected.to eq(value) }
      it('should return a copy') { is_expected.to_not be(value) }
    end
  end

  describe '::drop_box' do
    let(:value) { 'drop/box' }

    it('should have a default value') do
      expect(described_class.drop_box).to match %r{[^/][^ ]+}
    end

    context 'when setting a value' do
      subject { described_class.drop_box value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when getting the value' do
      before { described_class.drop_box value }
      subject { described_class.drop_box }
      it('should return it') { is_expected.to eq(value) }
      it('should return a copy') { is_expected.to_not be(value) }
    end
  end

  describe '::content_type' do
    let(:value) { :yaml }

    it('should be :text by default') do
      expect(described_class.content_type).to be(:text)
    end

    context 'when setting a value' do
      subject { described_class.content_type value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when setting :json' do
      before { described_class.content_type :json }
      it('should require JSON') { expect(defined? JSON).to_not be_nil }
    end

    context 'when setting :xml' do
      before { described_class.content_type :xml }
      it('should require Nokogiri') { expect(defined? Nokogiri).to_not be_nil }
    end

    context 'when setting :html' do
      before { described_class.content_type :html }
      it('should require Nokogiri') { expect(defined? Nokogiri).to_not be_nil }
    end

    context 'when getting the value' do
      before { described_class.content_type value }
      subject { described_class.content_type }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '::stocks_per_request' do
    let(:value) { 2 }

    it('should be 1 by default') do
      expect(described_class.stocks_per_request).to be(1)
    end

    context 'when setting a valid value' do
      subject { described_class.stocks_per_request value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when setting a float value' do
      before { described_class.stocks_per_request 1.2 }
      subject { described_class.stocks_per_request }
      it('should return an int value') { is_expected.to be_a(Fixnum) }
    end

    context 'when setting an invalid value' do
      before { described_class.stocks_per_request 0 }
      subject { described_class.stocks_per_request }
      it('should not accept it') { is_expected.to_not eq(0) }
    end

    context 'when getting the value' do
      before { described_class.stocks_per_request value }
      subject { described_class.stocks_per_request }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '::concurrent_requests' do
    let(:value) { 2 }

    it('should be 200 by default') do
      expect(described_class.concurrent_requests).to eq(200)
    end

    context 'when setting a valid value' do
      subject { described_class.concurrent_requests value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when setting a float value' do
      before { described_class.concurrent_requests 1.2 }
      subject { described_class.concurrent_requests }
      it('should return an int value') { is_expected.to be_a(Fixnum) }
    end

    context 'when setting an invalid value' do
      before { described_class.concurrent_requests 0 }
      subject { described_class.concurrent_requests }
      it('should not accept it') { is_expected.to_not eq(0) }
    end

    context 'when getting the value' do
      before { described_class.concurrent_requests value }
      subject { described_class.concurrent_requests }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '::parallel_requests' do
    let(:value) { 2 }

    it('should be 1 by default') do
      expect(described_class.parallel_requests).to eq(1)
    end

    context 'when setting a valid value' do
      subject { described_class.parallel_requests value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when setting a float value' do
      before { described_class.parallel_requests 1.2 }
      subject { described_class.parallel_requests }
      it('should return an int value') { is_expected.to be_a(Fixnum) }
    end

    context 'when setting an invalid value' do
      before { described_class.parallel_requests 0 }
      subject { described_class.parallel_requests }
      it('should not accept it') { is_expected.to_not eq(0) }
    end

    context 'when getting the value' do
      before { described_class.parallel_requests value }
      subject { described_class.parallel_requests }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '::request_timeout' do
    let(:value) { 2 }

    it('should have a default value') do
      expect(described_class.request_timeout).to be > 0
    end

    context 'when setting a valid value' do
      subject { described_class.request_timeout value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when setting a float value' do
      before { described_class.request_timeout 1.2 }
      subject { described_class.request_timeout }
      it('should return an int value') { is_expected.to be_a(Fixnum) }
    end

    context 'when setting an invalid value' do
      before { described_class.request_timeout 0 }
      subject { described_class.request_timeout }
      it('should not accept it') { is_expected.to_not eq(0) }
    end

    context 'when getting the value' do
      before { described_class.request_timeout value }
      subject { described_class.request_timeout }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '::base_url' do
    let(:value) { 'localhost/' }

    it('should be empty by default') do
      expect(described_class.base_url).to be_empty
    end

    context 'when setting a value' do
      subject { described_class.base_url value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when getting the value' do
      before { described_class.base_url value }
      subject { described_class.base_url }
      it('should return it') { is_expected.to eq(value) }
      it('should return a copy') { is_expected.to_not be(value) }
    end
  end

  describe '::serializer_class' do
    let(:value) { Class.new AppDax::Serializer }

    it('should have no default value') do
      expect(described_class.serializer_class).to be_nil
    end

    context 'when setting a class inherited from AppDax::Serializer' do
      subject { described_class.serializer_class value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when setting an invalid class' do
      before { described_class.serializer_class Fixnum }
      subject { described_class.serializer_class }
      it('should not accept it') { is_expected.to_not be(Fixnum) }
    end

    context 'when getting the value' do
      before { described_class.serializer_class value }
      subject { described_class.serializer_class }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '::stock_class' do
    let(:value) { Class.new AppDax::Stock }

    it('should have no default value') do
      expect(described_class.stock_class).to be_nil
    end

    context 'when setting a class inherited from AppDax::Stock' do
      subject { described_class.stock_class value }
      it('should return self') { is_expected.to be(described_class) }
    end

    context 'when setting an invalid class' do
      before { described_class.stock_class Fixnum }
      subject { described_class.stock_class }
      it('should not accept it') { is_expected.to_not be(Fixnum) }
    end

    context 'when getting the value' do
      before { described_class.stock_class value }
      subject { described_class.stock_class }
      it('should return it') { is_expected.to eq(value) }
    end
  end

  describe '::url_specs' do
    subject { described_class.url_specs }
    it('should return an empty hash by default') { is_expected.to eq({}) }
  end

  describe '::url_for_field' do
    context 'when calling without a block' do
      it do
        expect { described_class.url_for_field }.to raise_error(ArgumentError)
      end
    end

    context 'when passing no field' do
      before { described_class.url_for_field {} }
      subject { described_class.url_specs }
      it { is_expected.to include(nil) }
    end

    context 'when passing a field' do
      let(:field) { :f1 }
      before { described_class.url_for_field(field) {} }
      subject { described_class.url_specs }
      it { is_expected.to include(field) }
    end
  end

  describe '::config' do
    subject { described_class.config }
    it('should return an empty hash by default') { is_expected.to eq({}) }
  end

  describe '::load_config' do
    include FakeFS::SpecHelpers

    let(:load_config) { -> { described_class.load_config role: 'xyz' } }

    before { described_class.instance_variable_set :@fields, nil }

    context 'when file does not exist' do
      it { expect { load_config.call }.to_not raise_error }
    end

    context 'when role does not exist' do
      before do
        FileUtils.mkdir 'config'
        File.write 'config/scrape.yml', '{}'
      end

      it { expect { load_config.call }.to raise_error RuntimeError }
    end

    context 'when file and role exist' do
      subject { described_class.config }

      before do
        FileUtils.mkdir 'config'
        File.write 'config/scrape.yml', "xyz:\n  :fields:\n  - :f1"
        load_config.call
      end

      it('should have read config') { is_expected.to include(:fields) }

      context 'when config specified fields' do
        describe '::fields' do
          subject { described_class.fields }
          it('should return them') { is_expected.to eq([:f1]) }
        end
      end
    end
  end

  describe '::proxies' do
    require 'hidemyass'
    let!(:proxy) { HideMyAss::Proxy.new(nil) }
    let!(:url) { 'http://1.1.1.1:80' }
    subject { described_class.proxies }

    before do
      allow(proxy).to receive(:url).and_return(url)
      allow(HideMyAss).to receive(:proxies).and_return([proxy])
      allow(HideMyAss).to receive(:proxies!).and_return([proxy])
    end

    context 'when using proxy URLs' do
      before { described_class.use_proxies true }
      it('retuns proxies') { is_expected.to eq([url]) }
    end

    context 'when disabling proxies' do
      before { described_class.use_proxies false }
      it('retuns no proxies') { is_expected.to be_empty }
    end
  end
end
