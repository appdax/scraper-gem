
module AppDax
  # Each instance of class Stock indicates one finance security. The provided
  # informations are reaching from basic properties like name and ISIN over
  # intraday stats up to analyst recommendations and technical analysis results.
  #
  # @example Initializing a stock.
  #   stock = Stock.new(properties-from-consorsbank)
  #
  # @example Accessing the WKN code.
  #   stock.wkn
  #   #=> A1JWVX
  #
  # @example Get todays performance.
  #   stock.intra.performance
  #   #=> -1.59
  #
  # @example Convert the stock into a JSON structure
  #   stock.to_json
  #   #=> "{...}"
  class Stock
    # An instance indicates one finance security.
    #
    # @param [ Object ] raw The serialized raw data of the response.
    # @param [ String ] url The URL of the response.
    #
    # @return [ Stock ]
    def initialize(data, url = nil)
      @url  = url
      @data = data
    end

    # The serialized raw data
    #
    # @eturn [ Object ]
    attr_reader :data, :url

    alias exec instance_exec

    # Availability of the stock on cortal consors.
    #
    # @return [ Boolean ] A true value means available on that platform.
    def available?
      data && isin
    end

    # Basic properties of a finance security like the ISIN for ticker symbol.
    # As per default all methods return nil since the presence of them is
    # required.
    #
    # @return [ String ] nil
    %w(name wkn isin branch sector country symbol currency).each do |prop|
      define_method(prop) { nil }
    end
  end
end
