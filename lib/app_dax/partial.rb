require 'time'

module AppDax
  # Informations about a partial aspect of a stock.
  class Partial
    # Initialize a partial by applying the serialized subset of raw data.
    #
    # @param [ Hash ] data The serialized data from BNP Paribas.
    #
    # @return [ Partial ]
    def initialize(data)
      @data = data
    end

    attr_reader :data

    # Nach finnet scraper kopieren
    # alias page data

    # The date from the last update.
    #
    # @return [ String ] A string in ISO representation.
    def age_in_days
      diff_in_days Time.now
    end

    # If there are informations within the provided data.
    #
    # @return [ Boolean ] A true value means availability.
    def available?
      @data && !@data.empty?
    end

    # Call method equal to key and return the value.
    #
    # @param [Symbol] Method name.
    #
    # @return [ Object ]
    def [](key)
      public_send key
    rescue
      nil
    end

    # Executes the given block within the scope of the instance.
    #
    # @param [ Stock ] stock Stock instance that owns the partial.
    # @param [ Proc ] &block Code block to execute for.
    #
    # @return [ Object ] Returned result of the executed block.
    def exec(stock = nil, &block)
      instance_exec(stock, &block)
    end

    protected

    # Remove all nil values from object and return nil if empty.
    #
    # @example
    #   prune [1, nil]
    #   # => [1, nil]
    #
    # @example
    #   prune [nil]
    #   # => nil
    #
    # @example
    #   prune { k: 1 }
    #   # => { k: 1 }
    #
    # @example
    #   prune { k: nil }
    #   # => nil
    #
    # @param [ Array ] ary
    #
    # @return [ Array ]
    def prune(obj)
      return nil unless available?

      case obj
      when Array
        obj.clear if obj.all?(&:nil?)
      when Hash
        obj.delete_if { |_, v| v.nil? }
      end

      obj if obj.any?
    end

    # Calculate diff in days between today and the specified date.
    #
    # @param [Numeric|String|Date] obj The date to diff agains today.
    #
    # @return [ Int ]
    def diff_in_days(obj)
      return nil unless available? && obj

      date =  case obj
              when Numeric then Time.at(obj)
              when String then Time.parse(obj)
              else obj
              end.to_date

      (Date.today - date).to_i
    end

    # Return nil if the specified price has an invalid value.
    #
    # @param [ Int ] value
    #
    # @return [ Int ]
    def validate_price(value)
      value if value && value > 0
    end
  end
end
