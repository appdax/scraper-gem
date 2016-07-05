require 'app_dax/feed'
require 'forwardable'
require 'json'
require 'time'

module AppDax
  # JSON serializer for stock class. The serializer goes through all feeds,
  # generates their content and serializes them to one JSON encoded string.
  # If a feed is empty because maybe the partial isn't available then it will
  # not be included.
  class Serializer
    extend Forwardable

    # Accessor for the `feeds` property to specify the feeds to serialize into
    # a single data output.
    #
    # @example Setting of feeds.
    #   feeds FactSetFeed, PerformanceFeed
    #   # => self
    #
    # @example Get the feeds.
    #   feeds
    #   # => [FactSetFeed, PerformanceFeed]
    #
    # @param [ Array<? extends Feed> ] feeds A list of feed classes.
    #
    # @return [ Array<? extends Feed> ]
    def self.feeds(*feeds)
      @feeds   = feeds.flatten
                      .keep_if { |klass| klass < Feed } if feeds.any?
      @feeds ||= []

      feeds.any? ? self : @feeds.dup
    end

    # Accessor for the `source` property to specify the place from where
    # the data comes from.
    #
    # @example Setting the source.
    #   source :bloomberg
    #   # => self
    #
    # @example Get the source.
    #   source
    #   # => :bloomberg
    #
    # @param [ String ] name The name of the source.
    #
    # @return [ self ]
    def self.source(name = nil)
      @source = name if name

      name ? self : @source
    end

    instance_delegate source: 'self.class'

    # Instances of the (on class level) specified feed classes.
    #
    # @return [ Array<Feed> ]
    def feeds
      @feeds ||= self.class.feeds.map(&:new)
    end

    # Serializes the stock to JSON.
    #
    # @param [ Stock ] A serializable stock instance.
    #
    # @return [ String ]
    def serialize(stock)
      analyses = feeds.map { |feed| feed.generate(stock, source) }.compact

      return nil if analyses.empty?

      data = {
        source: source,
        created_at: Time.now.to_i,
        version: 1,
        basic: basic_data(stock),
        feeds: analyses
      }

      JSON.fast_generate(data, symbolize_names: false)
    end

    private

    # Extract basic stock data to serialize.
    #
    # @param [ Stock ]
    #
    # @return [ Hash ]
    def basic_data(stock)
      { name: stock.name,
        wkn: stock.wkn,
        isin: stock.isin,
        country: stock.country,
        branch: stock.branch,
        sector: stock.sector,
        symbol: stock.symbol,
        type: 1 }.delete_if { |_, v| v.nil? }
    end
  end
end
