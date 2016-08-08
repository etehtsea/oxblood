module Oxblood
  module Commands
    module Lists
      # Remove and get the first element in a list, or block until one
      # is available
      # @see http://redis.io/commands/blpop
      #
      # @param [String, Array<String>] keys
      # @param [Integer] timeout in seconds
      #
      # @return [nil] when no element could be popped and the timeout expired
      # @return [[String, String]] a two-element multi-bulk with the first
      #   element being the name of the key where an element was popped and
      #  the second element being the value of the popped element
      def blpop(*keys, timeout)
        blocking_pop(:BLPOP, keys, timeout)
      end

      # Remove and get the last element in a list, or block until one
      # is available
      # @see http://redis.io/commands/brpop
      #
      # @param [String, Array<String>] keys
      # @param [Integer] timeout in seconds
      #
      # @return [nil] when no element could be popped and the timeout expired
      # @return [[String, String]] a two-element multi-bulk with the first
      #   element being the name of the key where an element was popped and
      #  the second element being the value of the popped element
      def brpop(*keys, timeout)
        blocking_pop(:BRPOP, keys, timeout)
      end

      # Pop a value from a list, push it to another list and return it;
      # or block until one is available
      # @see http://redis.io/commands/brpoplpush
      #
      # @param [String] source
      # @param [String] destination
      #
      # @return [nil] when no element could be popped and the timeout expired
      # @return [String] the element being popped and pushed
      def brpoplpush(source, destination, timeout)
        blocking_pop(:BRPOPLPUSH, [source, destination], timeout)
      end

      # Get an element from a list by its index
      # @see http://www.redis.io/commands/lindex
      #
      # @param [String] key
      # @param [Integer] index zero-based of element in the list
      #
      # @return [String] the requested element, or nil when index is out of range.
      def lindex(key, index)
        run(:LINDEX, key, index)
      end

      # Insert an element before or after another element in a list
      # @see http://www.redis.io/commands/linsert
      #
      # @param [String] key
      # @param [Symbol] place could be :before or :after
      # @param [String] pivot reference value
      # @param [String] value to insert
      #
      # @return [Integer] the length of the list after the insert operation,
      # or -1 when the value pivot was not found
      def linsert(key, place, pivot, value)
        run(:LINSERT, key, place, pivot, value)
      end

      # Get the length of a list
      # @see http://redis.io/commands/llen
      #
      # @param [String] key
      #
      # @return [Integer] the length of the list at key
      # @return [RError] if the value stored at key is not a list
      def llen(key)
        run(:LLEN, key)
      end

      # Remove and get the first element in a list
      # @see http://redis.io/commands/lpop
      #
      # @param [String] key
      #
      # @return [String, nil] the value of the first element,
      #   or nil when key does not exist.
      def lpop(key)
        run(:LPOP, key)
      end

      # Prepend one or multiple values to a list
      # @see http://redis.io/commands/lpush
      #
      # @param [String] key
      # @param [Array] values to prepend
      #
      # @return [Integer] the length of the list after the push operations
      def lpush(key, *values)
        run(*values.unshift(:LPUSH, key))
      end

      # Prepend a value to a list, only if the list exists
      # @see http://www.redis.io/commands/lpushx
      #
      # @param [String] key
      # @param [String] value
      #
      # @return [Integer] the length of the list after the push operation
      def lpushx(key, value)
        run(:LPUSHX, key, value)
      end

      # Get a range of elements from a list
      # @see http://redis.io/commands/lrange
      #
      # @param [String] key
      # @param [Integer] start index
      # @param [Integer] stop index
      #
      # @return [Array] list of elements in the specified range
      def lrange(key, start, stop)
        run(:LRANGE, key, start, stop)
      end

      # Remove elements from a list
      # @see http://www.redis.io/commands/lrem
      #
      # @param [String] key
      # @param [Integer] count (please look into official docs for more info)
      # @param [String] value to remove
      #
      # @return [Integer] the number of removed elements
      def lrem(key, count, value)
        run(:LREM, key, count, value)
      end

      # Set the value of an element in a list by its index
      # @see http://www.redis.io/commands/lset
      #
      # @param [String] key
      # @param [Integer] index
      # @param [String] value
      #
      # @return [String] 'OK'
      # @return [RError] if index is out of range
      def lset(key, index, value)
        run(:LSET, key, index, value)
      end

      # Trim a list to the specified range
      # @see http://www.redis.io/commands/ltrim
      #
      # @param [String] key
      # @param [Integer] start
      # @param [Integer] stop
      #
      # @return [String] 'OK'
      def ltrim(key, start, stop)
        run(:LTRIM, key, start, stop)
      end

      # Remove and get the last element in a list
      # @see http://redis.io/commands/rpop
      #
      # @param [String] key
      #
      # @return [String, nil] the value of the last element, or nil when key does
      #   not exist
      def rpop(key)
        run(:RPOP, key)
      end

      # Remove the last element in a list, prepend it to another list and return
      # @see http://www.redis.io/commands/rpoplpush
      #
      # @param [String] source
      # @param [String] destination
      #
      # @return [String, nil] the element being popped and pushed, or nil when
      #   source does not exist
      def rpoplpush(source, destination)
        run(:RPOPLPUSH, source, destination)
      end

      # Append one or multiple values to a list
      # @see http://redis.io/commands/rpush
      #
      # @param [String] key
      # @param [Array] values to add
      #
      # @return [Integer] the length of the list after the push operation
      # @return [RError] if key holds a value that is not a list
      def rpush(key, *values)
        run(*values.unshift(:RPUSH, key))
      end

      # Append a value to a list, only if the list exists
      # @see http://www.redis.io/commands/rpushx
      #
      # @param [String] key
      # @param [String] value
      #
      # @return [Integer] the length of the list after the push operation
      def rpushx(key, value)
        run(:RPUSHX, key, value)
      end

      private

      # @note Mutates keys argument!
      def blocking_pop(command, keys, timeout)
        with_custom_timeout(timeout) do
          run(*keys.unshift(command).push(timeout))
        end
      end

      # Temporary increase socket timeout for blocking operations
      # @note non-threadsafe!
      def with_custom_timeout(timeout)
        old_timeout = connection.socket.timeout

        if timeout.zero?
          # Indefinite blocking means 0 on redis server and nil on ruby
          connection.socket.timeout = nil
        else
          connection.socket.timeout += timeout
        end

        yield
      ensure
        connection.socket.timeout = old_timeout
      end
    end
  end
end
