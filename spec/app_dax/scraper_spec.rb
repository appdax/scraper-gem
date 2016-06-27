require 'fakefs/spec_helpers'

RSpec.describe AppDax::Scraper do
  it do
    is_expected.to respond_to(*%w(fields drop_box stocks_per_request stock_class
                                  content_type process_timeout parallel_requests
                                  concurrent_requests serializer_class base_url))
  end

  describe '#run' do
    include FakeFS::SpecHelpers

    let(:scraper) { SpecScraper.content_type(content_type).new }
    let(:run) { -> { scraper.run ['AMZ:GR', 'AMZ:US'] } }

    before { allow(scraper).to receive(:fork) { |&block| block.call.to_i } }

    context 'when request timed out' do
      let(:content_type) { :text }
      before { stub_request(:get, %r{/markets/api}).to_timeout }
      it { expect { run.call }.to_not raise_error }
      it('should return 0') { expect(run.call).to be_zero }
    end

    context 'when request responds with 500' do
      let(:content_type) { :text }
      before { stub_request(:get, %r{/markets/api/}).to_return status: 503 }
      it { expect { run.call }.to_not raise_error }
    end

    context 'when responds body has unexpected content type' do
      before { stub_request(:get, %r{/markets/api/}).to_return body: 'busy' }

      context 'and content type is :text' do
        let(:content_type) { :text }
        it { expect { run.call }.to_not raise_error }
      end

      context 'and content type is :xml' do
        let(:content_type) { :xml }
        it { expect { run.call }.to_not raise_error }
      end

      context 'and content type is :html' do
        let(:content_type) { :html }
        it { expect { run.call }.to_not raise_error }
      end

      context 'and content type is :json' do
        let(:content_type) { :json }
        it { expect { run.call }.to_not raise_error }
      end
    end

    context 'when response body is valid' do
      let(:content_type) { :json }

      before { stub_request(:get, %r{/markets/api/}).to_return body: '{}' }

      it('should return count of scraped stocks') { expect(run.call).to be(2) }

      describe 'drop_box entries' do
        let(:entries) { Dir.glob "#{scraper.drop_box}/*.json" }
        before { run.call }
        it { expect(entries.count).to eq(2) }
        it('should be valid JSON files') do
          expect { JSON.parse(File.read(entries.first)) }.to_not raise_error
        end
      end
    end

    context 'when it takes to long time' do
      let(:content_type) { :json }

      before do
        stub_request(:get, %r{/markets/api/})
        scraper.parallel_requests 2
        allow(Timeout).to receive(:timeout).and_raise Timeout::Error
        allow(Process).to receive(:kill)
      end

      it('should return 0') { expect(run.call).to be(0) }
    end

    context 'when serialized stock is nil' do
      let(:content_type) { :json }

      before do
        stub_request(:get, %r{/markets/api/}).to_return body: '{}'
        allow_any_instance_of(SpecSerializer).to receive(:serialize)
          .and_return nil
      end

      describe 'drop_box' do
        subject { Dir.glob "#{scraper.drop_box}/*.json" }
        before { run.call }
        it { is_expected.to be_empty }
      end
    end
  end
end
