module Oxblood
  module Commands
    module Server
      # Remove all keys from the current database
      # @see http://redis.io/commands/flushdb
      #
      # @return [String] should always return 'OK'
      def flushdb
        run(:FLUSHDB)
      end

      # Returns information and statistics about the server in a format that is
      # simple to parse by computers and easy to read by humans
      # @see http://redis.io/commands/info
      #
      # @param [String] section used to select a specific section of information
      #
      # @return [String] raw redis server response as a collection of text lines.
      def info(section = nil)
        section ? run(:INFO, section) : run(:INFO)
      end
    end
  end
end
