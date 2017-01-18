require 'oxblood/commands/scan'

module Oxblood
  module Commands
    module Sets
      # Add one or more members to a set
      # @see http://redis.io/commands/sadd
      #
      # @param [String] key under which store set
      # @param [String, Array<String>] members to store
      #
      # @return [Integer] the number of elements that were added to the set,
      #   not including all the elements already present into the set.
      def sadd(key, *members)
        run(*members.unshift(:SADD, key))
      end

      # Get the number of members in a set
      # @see http://redis.io/commands/scard
      #
      # @param [String] key
      #
      # @return [Integer] the cardinality (number of elements) of the set, or 0 if
      #   key does not exist
      def scard(key)
        run(:SCARD, key)
      end

      # Subtract multiple sets
      # @see http://redis.io/commands/sdiff
      #
      # @param [String, Array<String>] keys
      #
      # @return [Array] array with members of the resulting set
      def sdiff(*keys)
        run(*keys.unshift(:SDIFF))
      end

      # Subtract multiple sets and store the resulting set in a key
      # @see http://redis.io/commands/sdiffstore
      #
      # @param [String] destination key
      # @param [String, Array<String>] keys of sets to diff
      #
      # @return [Integer] the number of elements in the resulting set
      def sdiffstore(destination, *keys)
        run(*keys.unshift(:SDIFFSTORE, destination))
      end

      # Intersect multiple sets
      # @see http://redis.io/commands/sinter
      #
      # @param [String, Array<String>] keys to intersect
      #
      # @return [Array] array with members of the resulting set
      def sinter(*keys)
        run(*keys.unshift(:SINTER))
      end

      # Intersect multiple sets and store the resulting key in a key
      # @see http://redis.io/commands/sinterstore
      #
      # @param [String] destination key
      # @param [String, Array<String>] keys of sets to intersect
      #
      # @return [Integer] the number of elements in the resulting set
      def sinterstore(destination, *keys)
        run(*keys.unshift(:SINTERSTORE, destination))
      end

      # Determine if a given value is a member of a set
      # @see http://redis.io/commands/sismember
      #
      # @param [String] key
      # @param [String] member
      #
      # @return [Integer] 1 if the element is a member of the set or
      #   0 if the element is not a member of the set, or if key does not exist
      def sismember(key, member)
        run(:SISMEMBER, key, member)
      end

      # Get all the members in a set
      # @see http://redis.io/commands/smembers
      #
      # @param [String] key
      #
      # @return [Array] all elements of the set
      def smembers(key)
        run(:SMEMBERS, key)
      end

      # Move a member from one set to another
      # @see http://redis.io/commands/smove
      #
      # @param [String] source
      # @param [String] destination
      # @param [String] member
      #
      # @return [Integer] 1 if the element is moved, or 0 if the element is not
      #   a member of source and no operation was performed
      def smove(source, destination, member)
        run(:SMOVE, source, destination, member)
      end

      # Remove and return one or multiple random members from a set
      # @see http://redis.io/commands/spop
      #
      # @param [String] key
      # @param [Integer] count
      #
      # @return [String] without the additional count argument the command returns
      #   the removed element, or nil when key does not exist
      # @return [Array] when the additional count argument is passed the command
      #   returns an array of removed elements, or an empty array when key does
      #   not exist.
      def spop(key, count = nil)
        args = [:SPOP, key]
        args << count if count
        run(*args)
      end

      # Get one or multiple random members from a set
      # @see http://redis.io/commands/srandmember
      #
      # @param [String] key
      # @param [Integer] count
      #
      # @return [String, nil] without the additional count argument the command
      #   returns string with the randomly selected element, or nil when key
      #   does not exist
      # @return [Array] when the additional count argument is passed the command
      #   returns an array of elements, or an empty array when key does not exist
      def srandmember(key, count = nil)
        args = [:SRANDMEMBER, key]
        args << count if count
        run(*args)
      end

      # Remove one or more members from a set
      # @see http://redis.io/commands/srem
      #
      # @param [String] key
      # @param [Array] members to remove
      #
      # @return [Integer] the number of members that were removed from the set,
      #   not including non existing members
      def srem(key, *members)
        run(*members.unshift(:SREM, key))
      end

      # Add multiple sets
      # @see http://redis.io/commands/sunion
      #
      # @param [String, Array<String>] keys
      #
      # @return [Array] list with members of the resulting set
      def sunion(*keys)
        run(*keys.unshift(:SUNION))
      end

      # Add multipe sets and store the resulting set in a key
      # @see http://redis.io/commands/sunionstore
      #
      # @param [String] destination
      # @param [String, Array<String>] keys
      #
      # @return [Integer] the number of elements in the resulting set
      def sunionstore(destination, *keys)
        run(*keys.unshift(:SUNIONSTORE, destination))
      end

      # Incrementally iterate Set elements
      # @see https://redis.io/commands/sscan
      #
      # @param [Integer] cursor
      # @param [Hash] opts
      #
      # @option opts [Integer] :count Amount of work that should be done at
      #   every call in order to retrieve elements from the collection.
      # @option opts [String] :match
      #
      # @return [Array] two elements array, where the first element is String
      #   representing an unsigned 64 bit number (the cursor), and the second
      #   element is an Array of elements.
      def sscan(key, cursor, opts = {})
        args = [:SSCAN, key, cursor]
        Scan.merge_opts!(args, opts)
        run(*args)
      end
    end
  end
end
