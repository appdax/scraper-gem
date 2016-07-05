
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

    # Accessor for the `id` property to specify the property that
    # identifies the stock instance. It defaults to the ISIN number.
    #
    # @example Set the identifier property.
    #   Stock.id :symbol
    #   # => self
    #
    # @example Get the identifier property.
    #   Stock.id
    #   # => :smybol
    #
    # @example Get the value of the identifier propery.
    #   stock.id
    #   # => 'AMZN'
    #
    # @param [ Symbol ] id The name of the property.
    #                      Possible values are :isin, :kwn and :symbol
    #
    # @return [ Stock ]
    def self.id(id = nil)
      unless [nil, :isin, :wkn, :symbol].include?(id)
        raise ArgumentError, 'Only :isin, :kwn or :symbol are allowed'
      end

      @id   = id if id
      @id ||= :isin

      id ? self : @id
    end

    # Get the value of the identifier propery.
    #
    # @return [ Object ]
    def id
      return @id if defined? @id
      id    = public_send(self.class.id)
      @id ||= id.to_s if id
    end

    # Availability of the stock on cortal consors.
    #
    # @return [ Boolean ] A true value means available on that platform.
    def available?
      data && id && !id.empty?
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
