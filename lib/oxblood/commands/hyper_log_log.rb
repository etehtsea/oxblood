module Oxblood
  module Commands
    module HyperLogLog
      # Adds the specified elements to the specified HyperLogLog.
      # @see https://redis.io/commands/pfadd
      #
      # @param [String] key
      # @param [String, Array<String>] elements
      #
      # @return [Integer] 1 if at least 1 HyperLogLog internal register was
      #   altered and 0 otherwise.
      def pfadd(key, *elements)
        run(*elements.unshift(:PFADD, key))
      end

      # Return the approximated cardinality of the set(s) observed by
      # the HyperLogLog at key(s).
      # @see https://redis.io/commands/pfcount
      #
      # @param [String, Array<String>] keys
      #
      # @return [Integer] the approximated number of unique elements observed
      #   via {pfadd}.
      def pfcount(*keys)
        run(*keys.unshift(:PFCOUNT))
      end

      # Merge N different HyperLogLogs into a single one.
      # @see https://redis.io/commands/pfmerge
      #
      # @param [String] destkey
      # @param [String, Array<String>] sourcekeys
      #
      # @return [String] 'OK'
      def pfmerge(destkey, *sourcekeys)
        run(*sourcekeys.unshift(:PFMERGE, destkey))
      end
    end
  end
end
