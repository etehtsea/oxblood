module Oxblood
  module Commands
    module Strings
      # Append a value to a key
      # @see http://redis.io/commands/append
      #
      # @param [String] key
      # @param [String] value
      #
      # @return [Integer] the length of the string after the append operation
      def append(key, value)
        run(:APPEND, key, value)
      end

      # Count set bits in a string
      # @see http://redis.io/commands/bitcount
      #
      # @param [String] key
      # @param [Array] interval to count in
      #
      # @return [Integer] the number of bits set to 1
      def bitcount(key, *interval)
        run(*interval.unshift(:BITCOUNT, key))
      end

      # Perform bitwise operations between strings
      # @see http://redis.io/commands/bitop
      #
      # @param [String] operation
      # @param [String] destkey
      # @param [Array] keys
      #
      # @return [Integer] the size of the string stored in the destination key,
      #   that is equal to the size of the longest input string
      def bitop(operation, destkey, *keys)
        run(*keys.unshift(:BITOP, operation, destkey))
      end

      # Find first bit set or clear in a string
      # @see http://redis.io/commands/bitpos
      #
      # @param [String] key
      # @param [Integer] bit
      # @param [Array] interval
      #
      # @return [Integer] the command returns the position of the first bit set to
      #   1 or 0 according to the request
      def bitpos(key, bit, *interval)
        run(*interval.unshift(:BITPOS, key, bit))
      end

      # Decrement the integer value of a key by one
      # @see http://redis.io/commands/decr
      #
      # @param [String] key
      #
      # @return [Integer] the value of key after the decrement
      # @return [RError] if value is not an integer or out of range
      def decr(key)
        run(:DECR, key)
      end

      # Decrement the integer value of a key by the given number
      # @see http://redis.io/commands/decrby
      #
      # @param [String] key
      # @param [Integer] decrement
      #
      # @return [Integer] the value of key after the decrement
      # @return [RError] if the key contains a value of the wrong type or contains
      #   a string that can not be represented as integer
      def decrby(key, decrement)
        run(:DECRBY, key, decrement)
      end

      # Get the value of a key
      # @see http://redis.io/commands/get
      #
      # @param [String] key
      #
      # @return [String, nil] the value of key, or nil when key does not exists
      def get(key)
        run(:GET, key)
      end

      # Returns the bit value at offset in the string value stored at key
      # @see http://redis.io/commands/getbit
      #
      # @param [String] key
      # @param [Integer] offset
      #
      # @return [Integer] the bit value stored at offset
      def getbit(key, offset)
        run(:GETBIT, key, offset)
      end

      # Get a substring of the string stored at a key
      # @see http://redis.io/commands/getrange
      #
      # @param [String] key
      # @param [Integer] start_pos
      # @param [Integer] end_pos
      #
      # @return [String] substring
      def getrange(key, start_pos, end_pos)
        run(:GETRANGE, key, start_pos, end_pos)
      end

      # Set the string value of a key and return its old value
      # @see http://redis.io/commands/getset
      #
      # @param [String] key
      # @param [String] value
      #
      # @return [String, nil] the old value stored at key, or nil when
      #   key did not exist
      def getset(key, value)
        run(:GETSET, key, value)
      end

      # Increment the integer value of a key by one
      # @see http://redis.io/commands/incr
      #
      # @param [String] key
      #
      # @return [Integer] the value of key after the increment
      # @return [RError] if the key contains a value of the wrong type or contains
      #   a string that can not be represented as integer
      def incr(key)
        run(:INCR, key)
      end

      # Increment the integer value of a key by the given amount
      # @see http://redis.io/commands/incrby
      #
      # @param [String] key
      # @param [Integer] increment
      #
      # @return [Integer] the value of key after the increment
      def incrby(key, increment)
        run(:INCRBY, key, increment)
      end

      # Increment the float value of a key by the given amount
      # @see http://redis.io/commands/incrbyfloat
      #
      # @param [String] key
      # @param [Float] increment
      #
      # @return [String] the value of key after the increment
      def incrbyfloat(key, increment)
        run(:INCRBYFLOAT, key, increment)
      end

      # Get the values of all the given keys
      # @see http://redis.io/commands/mget
      #
      # @param [Array<String>] keys to retrieve
      #
      # @return [Array] list of values at the specified keys
      def mget(*keys)
        run(*keys.unshift(:MGET))
      end

      # Set multiple keys to multiple values
      # @see http://redis.io/commands/mset
      #
      # @param [Array] keys_and_values
      #
      # @return [String] 'OK'
      def mset(*keys_and_values)
        run(*keys_and_values.unshift(:MSET))
      end

      # Set multiple keys to multiple values, only if none of the keys exist
      # @see http://redis.io/commands/msetnx
      #
      # @param [Array] keys_and_values
      #
      # @return [Integer] 1 if the all the keys were set, or
      #   0 if no key was set (at least one key already existed)
      def msetnx(*keys_and_values)
        run(*keys_and_values.unshift(:MSETNX))
      end

      # Set the value and expiration in milliseconds of a key
      # @see http://redis.io/commands/psetex
      #
      # @param [String] key
      # @param [Integer] milliseconds expire time
      # @param [String] value
      #
      # @return [String] 'OK'
      def psetex(key, milliseconds, value)
        run(:PSETEX, key, milliseconds, value)
      end

      # Set the string value of a key
      # @see http://redis.io/commands/set
      #
      # @todo Add support for set options
      #   http://redis.io/commands/set#options
      #
      # @param [String] key
      # @param [String] value
      #
      # @return [String] 'OK' if SET was executed correctly
      def set(key, value)
        run(:SET, key, value)
      end

      # Set or clear the bit at offset in the string value stored at key
      # @see http://redis.io/commands/setbit
      #
      # @param [String] key
      # @param [Integer] offset
      # @param [String] value
      #
      # @return [Integer] the original bit value stored at offset
      def setbit(key, offset, value)
        run(:SETBIT, key, offset, value)
      end

      # Set the value and expiration of a key
      # @see http://redis.io/commands/setex
      #
      # @param [String] key
      # @param [Integer] seconds expire time
      # @param [String] value
      #
      # @return [String] 'OK'
      def setex(key, seconds, value)
        run(:SETEX, key, seconds, value)
      end

      # Set the value of a key, only if the key does not exist
      # @see http://redis.io/commands/setnx
      #
      # @param [String] key
      # @param [String] value
      #
      # @return [Integer] 1 if the key was set, or 0 if the key was not set
      def setnx(key, value)
        run(:SETNX, key, value)
      end

      # Overwrite part of a string at key starting at the specified offset
      # @see http://redis.io/commands/setrange
      #
      # @param [String] key
      # @param [Integer] offset
      # @param [String] value
      #
      # @return [Integer] the length of the string after it was modified by
      #   the command
      def setrange(key, offset, value)
        run(:SETRANGE, key, offset, value)
      end

      # Get the length of the value stored in a key
      # @see http://redis.io/commands/strlen
      #
      # @param [String] key
      #
      # @return [Integer] the length of the string at key,
      #   or 0 when key does not exist
      def strlen(key)
        run(:STRLEN, key)
      end
    end
  end
end
