require 'app_dax/feed'

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
  class MultiFeed < Feed
    # Generate the feed to the provided stock.
    #
    # @param [ Stock ] stock The stock instance to convert to.
    # @param [ Symbol] source The name of the source.
    #
    # @return [ Hash ]
    def generate(stock, source)
      feed = super

      return nil unless feed

      feed.update(feed) { |_, v| v.is_a?(Array) ? v : [v] }

      meta = feed.delete(:meta)[0]
      size = feed.values[0].size

      items = (0...size).map do |i|
        feed.each_with_object({}) { |(k, v), item| item[k] = v[i] if v[i] }
      end

      { items: items, meta: meta.merge!(multi: true) }
    end
  end
end
