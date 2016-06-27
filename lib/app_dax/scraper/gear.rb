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
      # @return [ Array<Int>, IO, IO ] List of pids and IO pipes.
      def run_gear(isins, fields)
        forks  = []
        rd, wr = IO.pipe

        isins.each_slice(concurrent_requests) do |subset|
          if parallel_requests == 1
            wr.puts run_hydra(subset, fields)
          else
            forks << fork { wr.puts run_hydra(subset, fields) }
            wait_for(forks) if forks.count % parallel_requests == 0
          end
        end

        [forks, rd, wr]
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

      # Wait for finished execution of all forks, but not more then the
      # specified timeout in seconds in total.
      #
      # @param [ Array<Int> ] forks List of process pids.
      # @param [ Int ] timeout: Total time in seconds to wait for.
      #
      # @return [ Void ]
      def wait_for(forks, timeout: process_timeout)
        Timeout.timeout(timeout) { Process.waitall }
      rescue Timeout::Error
        kill_forks(forks)
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

        @count = 0
        @hydra.run

        @count
      end

      # Kill all child processes and wait for their exit to avoid zombies.
      #
      # @param [ Array<Int> ] pids Process PID numbers to kill.
      #
      # @return [ Void ]
      def kill_forks(pids)
        pids.each do |pid|
          begin
            Process.kill('INT', pid)
            Process.wait(pid)
          rescue Errno::ESRCH, Errno::ECHILD
            nil
          end
        end
      end
    end

    private_constant :Gear
  end
end
