require 'app_dax/scraper/class_methods'
require 'app_dax/scraper/gear'
require 'securerandom'
require 'forwardable'
require 'typhoeus'
require 'set'

module AppDax
  # To scrape all data about a stock from consorsbank.de the Scraper class takes
  # a list of of ISIN numbers and a set of fields to scrape for. Once a stock
  # beenscraped the date gets serialed to JSON string and written down into a
  # file.
  #
  # @example Scrape intraday data for facebook stock.
  #   Scraper.new.fields(:PriceV1).run ['US30303M1027']
  #
  # @example Scrape all data for facebook stock.
  #   Scraper.new.run ['US30303M1027']
  class Scraper
    extend ClassMethods
    extend Forwardable
    include Gear

    delegate %w(fields drop_box stocks_per_request content_type
                base_url process_timeout concurrent_requests config
                parallel_requests serializer_class stock_class) => 'self.class'

    # Intialize the scraper and create the hydra and serializer
    # for later usage.
    #
    # @return [ Scraper ]
    def initialize
      @hydra      = Typhoeus::Hydra.new
      @serializer = serializer_class.new
      @isins      = Set.new
    end

    # Run the hydra with the given ISIN numbers to scrape their data.
    #
    # @example Scrape Facebook Inc.
    #   run('US30303M1027')
    #
    # @example Scrape Facebook and Amazon
    #   run('US30303M1027', 'US0231351067')
    #
    # @param [ Array<String> ] isins List of ISIN numbers.
    #
    # @return [ Int ] Total number of scraped stocks.
    def run(isins)
      FileUtils.mkdir_p drop_box

      return 0 if isins.empty?

      pids, *pipes = run_gear(isins, fields)

      wait_for(pids)
      sum_scraped_stocks(*pipes)
    end

    private

    # Scrape the content of the stock specified by his ISIN number.
    # The method workd async as the `on_complete` callback of the response
    # object delegates to the fetchers `on_complete` method.
    #
    # @example Scrape Facebook Inc.
    #   scrape('US30303M1027')
    #
    # @param [ Array<String> ] isins Set of ISIN numbers.
    # @param [ Array<Symbol> ] fields List of fields to scrape for.
    #
    # @return [ Void ]
    def scrape(isins, fields)
      urls = urls_for(isins, fields)

      urls.each do |url|
        req = Typhoeus::Request.new(url)
        req.on_complete(&method(:on_complete))
        @hydra.queue(req)
      end
    end

    # Callback of the `scrape` method once the request is complete.
    # The containing stocks will be saved to into a file. If the list is
    # paginated then the linked pages will be added to the queue.
    #
    # @param [ Typhoeus::Response ] res The response of the HTTP request.
    #
    # @return [ Void ]
    def on_complete(res)
      data = parse_response(res)
      data = [data] unless data.is_a? Array

      data.each do |json|
        stock = stock_class.new(json, res.effective_url.to_s)

        next unless stock.available?

        save_stock_as_json(stock)
        @isins << stock.isin
      end
    end

    # Save the scraped stock data in a file under @drop_box dir.
    #
    # @param [ Stock ] stock
    def save_stock_as_json(stock)
      filepath = File.join(drop_box, filename_for(stock))
      json     = @serializer.serialize(stock)

      File.write(filepath, json) if json
    end

    protected

    # Parses the response body to an array of raw stock data.
    #
    # @param [ res ] The response.
    #
    # @return [ Array<Object> ] The parsed response body.
    def parse_response(res)
      return [] unless res.success?

      case content_type
      when :json
        parse_json_response(res)
      when :html, :xml
        parse_html_response(res)
      else
        [res.body]
      end
    end

    # Build url to request the content of the specified fields of the stock.
    #
    # @example URL to get the basic data only.
    #   url_for 'US30303M1027'
    #   #=> 'stocks?field=BasicV1&id=US30303M1027'
    #
    # @example URL to get the basic and performance data.
    #   url_for 'US30303M1027'
    #   #=> 'stocks?field=BasicV1&field=PerformanceV1&id=US30303M1027'
    #
    # @param [ Array<String> ] isins The ISIN numbers of the specified stock.
    # @param [ Array<Symbol> ] fields A subset of Scraper::FIELDS.
    #
    # @return [ Array<String> ]
    def urls_for(isins, fields = [])
      symbols = stocks_per_request == 1 ? isins.first : isins
      specs   = self.class.url_specs

      fields.map do |(field, block)|
        block = specs[field] || specs[nil]

        raise ArgumentError,
              "Dont know how to build url for field #{field}." unless block

        instance_exec(field, symbols, &block)
      end.uniq.compact
    end

    private

    # Parses the json response body.
    #
    # @param [ res ] The response with JSON encoded body.
    #
    # @return [ Object ] The parsed ruby object.
    def parse_json_response(res)
      JSON.parse(res.body, symbolize_names: true)
    rescue JSON::ParserError
      []
    end

    # Parses the xml/html response body.
    #
    # @param [ res ] The response with JSON encoded body.
    #
    # @return [ Object ] The parsed ruby object.
    def parse_html_response(res)
      Nokogiri::HTML(res.body, nil, 'UTF-8')
    end

    # Generate a filename for a stock.
    #
    # @example Filename for Facebook stock
    #   filename_for(facebook)
    #   #=> 'facebook-01bff156-5e39-4c13-b35a-8380814ef07f.json'
    #
    # @param [ Stock ] stock The specified stock.
    #
    # @return [ String ] A filename of a JSON file.
    def filename_for(stock)
      "#{stock.id}-#{SecureRandom.uuid}.json"
    end
  end
end
