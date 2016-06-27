require 'app_dax/multi_partial'

module AppDax
  # Base class for stock feeds. Each feed consists of 3 parts:
  #  - Meta tags
  #  - Simple 1:1 mapping kpis
  #  - More complex or individual kpis
  #
  # The Feed class provides a DSL to easily configure a Feed.
  #
  # class TheScreenerFeed < Feed
  #   kpis_from screener: %i(per risk interest)
  #   kpi(:volatility, from: :risk) { volatility(1) }
  # end
  class Feed
    # The name of the feed.
    #
    # @example Get the name of FactSetFeed class.
    #   FactSetFeed.feed_name
    #   #=> :fact_set
    #
    # @return [ Symbol ]
    def self.feed_name
      @feed ||= name.scan(/(.*)Feed$/)[0][0].downcase!
    end

    # The age in days of the feeds data.
    #
    # @example The partial that holds the age.
    #   age_from :screener
    #
    # @param [ Symbol ] name The name of the partial.
    #
    # @return [ Void ]
    def self.age_from(name = nil)
      @age_from = name if name
      @age_from
    end

    # Add meta tag to the feed.
    #
    # @example Set currency for some kpis.
    #   meta(:currency) { 'EUR' }
    #
    # @param [ Symbol ] The name of the meta tag.
    # @param [ Proc] block Executable piece of code.
    #
    # @return [ Hash ]
    def self.meta(name = nil, &block)
      (@meta ||= {})[name] = block if name
      @meta
    end

    # Specify the kpis to extract from the named partial.
    #
    # @example To have some kpis from stock.screener use
    #   kpis_from screener: %i(bad_news bear_market)
    #
    # @param [ Hash ] map A hash map where the keys point to stock partials
    #                     and the values are names of kpis of these partials.
    #
    # @return [ Void ]
    def self.kpis_from(map)
      @kpis ||= {}
      map.each_pair { |name, kpis| (@kpis[name] ||= []).concat kpis }
    end

    # Specify an individual more complex kpi value.
    #
    # @example To specify the volatility kpi
    #   kpi(:volatility, from: :risk) { { '1m': volatility(1) } }
    #
    # @param [ Symbol ] name The name of the kpi.
    # @param [ Symbol ] from: The optional name of the partial.
    # @param [ Proc ] Code block to execute within the scope of the partial.
    #
    # @return [ Void ]
    def self.kpi(name, from: nil, &block)
      (@nodes ||= {})[name] = [from, block]
    end

    # The configuration of the feed.
    #
    # @example Get config of simple and complex kpis.
    #   config
    #   #=> { simple: {..}, complex: {..} }
    #
    # @return [ Hash ]
    def self.kpis
      { simple: @kpis, complex: @nodes }
    end

    # Generate the feed to the provided stock.
    #
    # @param [ Stock ] stock The stock instance to convert to.
    # @param [ Symbol] source The name of the source.
    #
    # @return [ Hash ]
    def generate(stock, source)
      kpis = kpis(stock)

      return nil if kpis.empty?

      meta = metas(stock).merge!(source: source, feed: self.class.feed_name)

      kpis.merge!(meta: meta)
    end

    private

    # The timestamp of the feed.
    #
    # @param [ Stock ] stock The stock instance to convert to.
    #
    # @return [ Int ]
    def age_in_days(stock)
      partial = stock.public_send(self.class.age_from)

      partial.age_in_days
    end

    # The meta tags for the stock including the timestamp.
    #
    # @param [ Stock ] stock The stock instance to convert to.
    #
    # @return [ Hash ]
    def metas(stock)
      nodes = { age: age_in_days(stock) }
      cfg   = self.class.meta

      cfg.each_pair { |name, block| nodes[name] = block.call(stock) } if cfg

      nodes
    end

    # Basic, simple and complex kpis from the stock.
    #
    # @param [ Stock ] stock The stock instance to convert to.
    #
    # @return [ Hash ]
    def kpis(stock)
      simple_kpis(stock).merge!(complex_kpis(stock))
    end

    # Extract all simple key => value kpis from the stock.
    #
    # @param [ Stock ] stock The stock instance to convert to.
    #
    # @return [ Hash ]
    def simple_kpis(stock)
      kpis = self.class.kpis[:simple]

      return {} unless kpis

      kpis.each_with_object({}) do |(name, keys), map|
        partial = stock.public_send(name)
        next unless partial.available?
        keys.each { |key| store_kpi(map, key, partial[key]) }
      end
    end

    # Extract all more complex kpis from the stock.
    #
    # @param [ Stock ] stock The stock instance to convert to.
    #
    # @return [ Hash ]
    def complex_kpis(stock)
      nodes = self.class.kpis[:complex]

      return {} unless nodes

      nodes.each_with_object({}) do |(name, (scope, block)), map|
        partial = scope ? stock.public_send(scope) : stock
        next unless partial.available?
        store_kpi(map, name, partial.exec(stock, &block))
      end
    end

    # Store key-value pair only if value is not nil.
    #
    # @param [ Hash ] hsh
    # @param [ Symbol ] key
    # @param [ Object ] value
    #
    # @return [ Hash ] hsh
    def store_kpi(hsh, key, value)
      hsh[key] = value unless value.nil?
      hsh
    end
  end
end
