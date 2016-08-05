module Oxblood
  module Commands
    module SortedSets
      # Add one or more members to a sorted set, or update its score if it already
      # exists.
      # @see http://redis.io/commands/zadd
      #
      # @todo Add support for zadd options
      #   http://redis.io/commands/zadd#zadd-options-redis-302-or-greater
      #
      # @param [String] key under which store set
      # @param [[Float, String], Array<[Float, String]>] args scores and members
      #
      # @return [Integer] The number of elements added to the sorted sets, not
      #   including elements already existing for which the score was updated
      def zadd(key, *args)
        run(*args.unshift(:ZADD, key))
      end

      # Get the number of members in a sorted set
      # @see http://redis.io/commands/zcard
      #
      # @param [String] key
      #
      # @return [Integer] the cardinality (number of elements) of the sorted set,
      #   or 0 if key does not exists
      def zcard(key)
        run(:ZCARD, key)
      end

      # Count the members in a sorted set with scores within the given values
      # @see http://redis.io/commands/zcount
      #
      # @param [String] key
      # @param [String] min
      # @param [String] max
      #
      # @return [Integer] the number of elements in the specified score range
      def zcount(key, min, max)
        run(:ZCOUNT, key, min, max)
      end

      # Increment the score of a member in a sorted set
      # @see http://redis.io/commands/zincrby
      #
      # @param [String] key
      # @param [Float] increment
      # @param [String] member
      #
      # @return [String] the new score of member (a double precision floating
      #   point number), represented as string
      def zincrby(key, increment, member)
        run(:ZINCRBY, key, increment, member)
      end

      # Count the number of members in a sorted set between a given
      # lexicographical range
      # @see http://redis.io/commands/zlexcount
      #
      # @param [String] key
      # @param [String] min
      # @param [String] max
      #
      # @return the number of elements in the specified score range
      def zlexcount(key, min, max)
        run(:ZLEXCOUNT, key, min, max)
      end

      # Return a range of members in a sorted set, by index
      # @see http://redis.io/commands/zrange
      #
      # @example
      #   session.zrange('myzset', 0, -1)
      #   # => ['one', 'two']
      #
      # @example
      #   session.zrange('myzset', 0, -1, withscores: true)
      #   # => [['one', '1'], ['two', '2']]
      #
      # @param [String] key
      # @param [Integer] start index
      # @param [Integer] stop index
      # @param [Hash] opts
      #
      # @option opts [Boolean] :withscores (false) Return the scores of
      #   the elements together with the elements
      #
      # @return [Array] list of elements in the specified range (optionally with
      #   their scores, in case the :withscores option is given)
      def zrange(key, start, stop, opts = {})
        args = [:ZRANGE, key, start, stop]
        args << :WITHSCORES if opts[:withscores]
        run(*args)
      end

      # Return a range of members in a sorted set, by score
      # @see http://redis.io/commands/zrangebyscore
      #
      # @param [String] key under which set is stored
      # @param [String] min score
      # @param [String] max score
      # @param [Hash] opts
      #
      # @option opts [Boolean] :withscores (false) Return the scores of
      #   the elements together with the elements
      # @option opts [Array<Integer, Integer>] :limit Get a range of the matching
      #   elements (similar to SELECT LIMIT offset, count in SQL)
      #
      # @example
      #   session.zrangebyscore('myzset', '-inf', '+inf')
      #   # => ['one', 'two', 'three']
      #
      # @example
      #   session.zrangebyscore('myzset', '(1', 2, withscores: true)
      #   # => [['two', '2']]
      #
      # @example
      #   opts = { withscores: true, limit: [1, 1] }
      #   session.zrangebyscore('myzset', '-inf', '+inf', opts)
      #   # => [['two', '2']]
      #
      # @return [Array] list of elements in the specified score range (optionally
      #   with their scores, in case the :withscores option is given)
      def zrangebyscore(key, min, max, opts = {})
        args = [:ZRANGEBYSCORE, key, min, max]
        args << :WITHSCORES if opts[:withscores]
        args.push(:LIMIT).concat(opts[:limit]) if opts[:limit].is_a?(Array)

        run(*args)
      end

      # Determine the index of a member in a sorted set
      # @see http://redis.io/commands/zrank
      #
      # @param [String] key
      # @param [String] member
      #
      # @return [Integer, nil] the rank of member or nil if member does not exist
      # in the sorted set or key does not exist
      def zrank(key, member)
        run(:ZRANK, key, member)
      end

      # Remove one or more members from a sorted set
      # @see http://redis.io/commands/zrem
      #
      # @param [String] key
      # @param [Array<String>] members to delete
      #
      # @return [Integer] number of deleted members
      # @return [RError] when key exists and does not hold a sorted set.
      def zrem(key, *members)
        run(*members.unshift(:ZREM, key))
      end

      # Remove all members in a sorted set within the given indexes
      # @see http://redis.io/commands/zremrangebyrank
      #
      # @param [String] key
      # @param [String] start
      # @param [String] stop
      #
      # @return [Integer] the number of elements removed
      def zremrangebyrank(key, start, stop)
        run(:ZREMRANGEBYRANK, key, start, stop)
      end

      # Remove all members in a sorted set within the given scores
      # @see http://redis.io/commands/zremrangebyscore
      #
      # @param [String] key
      # @param [String] min score
      # @param [String] max score
      #
      # @return [Integer] the number of elements removed
      def zremrangebyscore(key, min, max)
        run(:ZREMRANGEBYSCORE, key, min, max)
      end

      # Return a range of members in a sorted set, by index, with scores ordered
      # from high to low
      # @see http://redis.io/commands/zrevrange
      #
      # @example
      #   session.zrevrange('myzset', 0, -1)
      #   # => ['two', 'one']
      #
      # @example
      #   session.zrevrange('myzset', 0, -1, withscores: true)
      #   # => [['two', '2'], ['one', '1']]
      #
      # @param [String] key
      # @param [Integer] start index
      # @param [Integer] stop index
      # @param [Hash] opts
      #
      # @option opts [Boolean] :withscores (false) Return the scores of
      #   the elements together with the elements
      #
      # @return [Array] list of elements in the specified range (optionally with
      #   their scores, in case the :withscores option is given)
      def zrevrange(key, start, stop, opts = {})
        args = [:ZREVRANGE, key, start, stop]
        args << :WITHSCORES if opts[:withscores]
        run(*args)
      end

      # Return a range of members in a sorted set, by score, with scores ordered
      # from high to low
      # @see http://redis.io/commands/zrevrangebyscore
      #
      # @param [String] key under which set is stored
      # @param [String] min score
      # @param [String] max score
      # @param [Hash] opts
      #
      # @option opts [Boolean] :withscores (false) Return the scores of
      #   the elements together with the elements
      # @option opts [Array<Integer, Integer>] :limit Get a range of the matching
      #   elements (similar to SELECT LIMIT offset, count in SQL)
      #
      # @example
      #   session.zrevrangebyscore('myzset', '+inf', '-inf')
      #   # => ['three', 'two', 'one']
      #
      # @example
      #   session.zrevrangebyscore('myzset', 2, '(1', withscores: true)
      #   # => [['two', '2']]
      #
      # @example
      #   opts = { withscores: true, limit: [1, 1] }
      #   session.zrevrangebyscore('myzset', '+inf', '-inf', opts)
      #   # => [['two', '2']]
      #
      # @return [Array] list of elements in the specified score range (optionally
      #   with their scores, in case the :withscores option is given)
      def zrevrangebyscore(key, min, max, opts = {})
        args = [:ZREVRANGEBYSCORE, key, min, max]
        args << :WITHSCORES if opts[:withscores]
        args.push(:LIMIT).concat(opts[:limit]) if opts[:limit].is_a?(Array)

        run(*args)
      end

      # Determine the index of a member in a sorted set, with scores ordered from
      # high to low
      # @see http://redis.io/commands/zrevrank
      #
      # @param [String] key
      # @param [String] member
      #
      # @return [Integer, nil] the rank of member, or nil if member does not
      # exists in the sorted set or key does not exists
      def zrevrank(key, member)
        run(:ZREVRANK, key, member)
      end

      # Get the score associated with the given member in a sorted set
      # @see http://redis.io/commands/zscore
      #
      # @param [String] key
      # @param [String] member
      #
      # @return [String, nil] the score of member (a double precision floating
      # point number), represented as string, or nil if member does not exist in
      # the sorted set, or key does not exists
      def zscore(key, member)
        run(:ZSCORE, key, member)
      end
    end
  end
end
