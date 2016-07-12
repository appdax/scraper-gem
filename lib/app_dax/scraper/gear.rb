require 'timeout'

module AppDax
  # This is an empty top-level class comment to satisfy rubocop.
  class Scraper
    # Gear logic of a scraper to boot-up child processes and
    # handle the communication between them.
    module Gear
      # Slice the list of ISINs into smaller chunks and create multiple forks
      # to scrape them.
      #
      # @param [ Array<String> ] isins List of ISIN numbers.
      # @param [ Array<Symbol> ] fields: Subset of Scraper::FIELDS.
      #
      # @return [ IO, IO ] Read and write pipes
      def run_gear(isins, fields)
        rd, wr = IO.pipe

        in_groups_of(parallel_requests, isins).each do |subset|
          if parallel_requests == 1
            wr.puts run_hydra(subset, fields)
          else
            fork { wr.puts run_hydra(subset, fields) }
          end
        end

        [rd, wr]
      end

      protected

      # Sum the numbers included in the provided pipes and close them.
      #
      # @param [ IO ] rd Pipe to read the content.
      # @param [ IO ] wr Pipe to write in the content.
      #
      # @return [ Void ]
      def sum_scraped_stocks(rd, wr)
        wr.close
        rd.read.split.map!(&:to_i).reduce(&:+)
      ensure
        rd.close
      end

      private

      # Run the hydra for the given set of ISINs.
      #
      # @param [ Array<String> ] isins List of ISIN numbers.
      # @param [ Array<Symbol> ] fields: Subset of Scraper::FIELDS.
      #
      # @return [ Int ] Number of scraped stocks.
      def run_hydra(isins, fields)
        isins.each_slice(stocks_per_request) { |stocks| scrape stocks, fields }

        @stock_ids.clear
        @hydra.max_concurrency = concurrent_requests / parallel_requests
        @hydra.run

        @stock_ids.count
      end

      # Splits an enumerable object into n groups.
      #
      # @param [ Int ] count The number of groups.
      # @param [ Enumerable ] enum The enumerable object like an array.
      #
      # @return [ Enumerator ]
      def in_groups_of(count, enum)
        division = enum.size.div count
        modulo   = enum.size % count

        enum.each_slice(division + modulo)
      end
    end

    private_constant :Gear
  end
end
