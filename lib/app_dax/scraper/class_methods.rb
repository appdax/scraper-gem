require 'app_dax/serializer'
require 'app_dax/stock'

module AppDax
  # This is an empty top-level class comment to satisfy rubocop.
  class Scraper
    # Interface methods to configure the scraper on class level.
    module ClassMethods
      # Accessor for the `fields` property to specify the possible and
      # default fields to scrape for.
      #
      # @example Setting of fields.
      #   fields :macd, :rsi
      #   # => self
      #
      # @example Get the fields.
      #   fields
      #   # => [:macd, :rsi]
      #
      # @param [ Array<Symbol> ] *fields Optional list of field names.
      #
      # @return [ Scraper ]
      def fields(*fields)
        @fields   = fields.flatten if fields && fields.any?
        @fields ||= []

        fields && fields.any? ? self : @fields.dup
      end

      # Accessor for the `drop_box` property to specify the place
      # where to put the data.
      #
      # @example Setter
      #   drop_box 'tmp/stocks'
      #   # => self
      #
      # @example Getter
      #   drop_box
      #   # => 'tmp/stocks'
      #
      # @param [ String ] path Optional path where to place the stock data.
      #
      # @return [ Scraper ]
      def drop_box(path = nil)
        @drop_box   = path.to_s if path
        @drop_box ||= 'tmp/stocks'

        path ? self : @drop_box.dup
      end

      # Accessor for the `content_type` property to specify how to parse the
      # response body.
      #
      # Notice that in case of another content type as :json, :xml, :html
      # or generic :text its required to override the `parse_response` method.
      #
      # @example Setter
      #   content_type :json
      #   # => self
      #
      # @example Getter
      #   content_type
      #   # => :json
      #
      # @param [ Symbol ] type Optional content type.
      #                        Defaults to: :text
      #
      # @return [ Scraper ]
      def content_type(type = nil)
        @content_type   = type if type
        @content_type ||= :text

        case @content_type
        when :json       then require 'json'
        when :html, :xml then require 'nokogiri'
        end

        type ? self : @content_type
      end

      # Accessor for the `stocks_per_request` property to specify the maximum
      # amount of stocks to put into one requests.
      #
      # @example Setter
      #   stocks_per_request 500
      #   # => self
      #
      # @example Getter
      #   stocks_per_request
      #   # => 500
      #
      # @param [ Int ] count Defaults to 1.
      #
      # @return [ Scraper ]
      def stocks_per_request(count = nil)
        @per_request   = count.to_i if count && count.to_i >= 1
        @per_request ||= 1

        count ? self : @per_request
      end

      # Accessor for the `concurrent_requests` property to specify the maximum
      # amount of concurrent requests per hydra.
      #
      # @example Setter
      #   concurrent_requests 200
      #   # => self
      #
      # @example Getter
      #   concurrent_requests
      #   # => 200
      #
      # @param [ Int ] count Optional limit of concurrent requests.
      #                      Defaults to 200.
      #
      # @return [ Scraper ]
      def concurrent_requests(count = nil)
        @concurrent   = count.to_i if count && count.to_i >= 1
        @concurrent ||= 200

        count ? self : @concurrent
      end

      # Accessor for the `parallel_requests` property to specify
      # the maximum amount of parallel requests (child processes).
      #
      # @example Setter
      #   parallel_requests 2
      #   # => self
      #
      # @example Getter
      #   parallel_requests
      #   # => 2
      #
      # @param [ Int ] count Optional limit of parallel requests.
      #                      Defaults to 1.
      #
      # @return [ Scraper ]
      def parallel_requests(count = nil)
        @parallel   = count.to_i if count && count.to_i >= 1
        @parallel ||= 1

        count ? self : @parallel
      end

      # Accessor for the `process_timeout` property to specify the maximum
      # amount of seconds to wait for a forked child process before being
      # killed.
      #
      # @example Setter
      #   process_timeout 30
      #   # => self
      #
      # @example Getter
      #   process_timeout
      #   # => 30
      #
      # @param [ Int ] count Optional Timeout in seconds.
      #                      Defaults to 20.
      #
      # @return [ Scraper ]
      def process_timeout(count = nil)
        @process_timeout   = count.to_i if count && count.to_i >= 1
        @process_timeout ||= 20

        count ? self : @process_timeout
      end

      # Accessor for the `base_url` property to specify the prefix for all URIs.
      #
      # @example Setter
      #   base_url 'https://www.bloomberg.com/markets/api'
      #   # => self
      #
      # @example Getter
      #   base_url
      #   # => 'https://www.bloomberg.com/markets/api'
      #
      # @param [ String ] url Optional url.
      #
      # @return [ Void ]
      def base_url(url = nil)
        @base_url   = url.to_s if url
        @base_url ||= ''

        url ? self : @base_url.dup
      end

      # Accessor for the `serializer_class` property to specify the class
      # which is responsible for serializing the stock instances.
      #
      # @example Setter
      #   serializer_class MySerializer
      #   # => self
      #
      # @example Getter
      #   serializer_class
      #   # => MySerializer
      #
      # @param [ AppDax::Serializer ] serializer The serializer class.
      #
      # @return [ AppDax::Serializer ]
      def serializer_class(klass = nil)
        @serializer_class = klass if klass && klass < Serializer

        klass ? self : @serializer_class
      end

      # Accessor for the `stock_class` property to specify the class
      # which wraps all partials of one stock.
      #
      # @example Setter
      #   stock_class MyStock
      #   # => self
      #
      # @example Getter
      #   stock_class
      #   # => MyStock
      #
      # @param [ AppDax::Stock ] stock The stock class.
      #
      # @return [ AppDax::Stock ]
      def stock_class(klass = nil)
        @stock_class = klass if klass && klass < Stock

        klass ? self : @stock_class
      end

      # Define how to build the URL for a specific field.
      #
      # @example URL for any field.
      #   url_for_field { |field, stock| "#{base_url}/#{field}/#{stock}" }
      #
      # @example URL for specific field.
      #   url_for_field(:macd) { |_, stock| "#{base_url}/macd/#{stock}" }
      #
      # @param [ Symbol ] field A optional field name.
      #                         Defaults to: Any field.
      #
      # @param [ Proc ] A code block to execute later.
      #
      # @return [ Void ]
      def url_for_field(field = nil, &block)
        @url_specs ||= {}
        @url_specs[field] = block if block_given?

        raise ArgumentError, 'no block given' unless block_given?

        self
      end

      # Previously specified specs to build the URL for a field.
      #
      # @return [ Hash ]
      def url_specs
        (@url_specs ||= {}).dup
      end
    end

    private_constant :ClassMethods
  end
end
