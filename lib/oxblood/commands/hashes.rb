module Oxblood
  module Commands
    module Hashes
      # Removes the specified fields from the hash stored at key
      # @see http://redis.io/commands/hdel
      #
      # @param [String] key under which hash is stored
      # @param [Array<#to_s>] fields to delete
      #
      # @return [Integer] the number of fields that were removed from the hash
      def hdel(key, fields)
        run(:HDEL, key, fields)
      end

      # Returns if field is an existing field in the hash stored at key
      # @see http://redis.io/commands/hexists
      #
      # @param [String] key under which hash is stored
      # @param [String] field to check for existence
      #
      # @return [Integer] 1 if the hash contains field and 0 otherwise
      def hexists(key, field)
        run(:HEXISTS, key, field)
      end

      # Get the value of a hash field
      # @see http://redis.io/commands/hget
      #
      # @param [String] key under which hash is stored
      # @param [String] field name
      #
      # @return [String, nil] the value associated with field
      #   or nil when field is not present in the hash or key does not exist.
      def hget(key, field)
        run(:HGET, key, field)
      end

      # Get all the fields and values in a hash
      # @see http://redis.io/commands/hgetall
      #
      # @param [String] key under which hash is stored
      #
      # @return [Array] list of fields and their values stored in the hash,
      #   or an empty list when key does not exist.
      def hgetall(key)
        run(:HGETALL, key)
      end

      # Increment the integer value of a hash field by the given number
      # @see http://redis.io/commands/hincrby
      #
      # @param [String] key under which hash is stored
      # @param [String] field to increment
      # @param [Integer] increment by value
      #
      # @return [Integer] the value at field after the increment operation
      def hincrby(key, field, increment)
        run(:HINCRBY, key, field, increment)
      end

      # Increment the float value of a hash field by the given number
      # @see http://redis.io/commands/hincrby
      #
      # @param [String] key under which hash is stored
      # @param [String] field to increment
      # @param [Integer] increment by value
      #
      # @return [String] the value of field after the increment
      # @return [RError] field contains a value of the wrong type (not a string).
      #   Or the current field content or the specified increment are not parsable
      #   as a double precision floating point number.
      def hincrbyfloat(key, field, increment)
        run(:HINCRBYFLOAT, key, field, increment)
      end

      # Get all the keys in a hash
      # @see http://redis.io/commands/hkeys
      #
      # @param [String] key
      #
      # @return [Array] list of fields in the hash, or an empty list when
      #   key does not exist.
      def hkeys(key)
        run(:HKEYS, key)
      end

      # Get the number of keys in a hash
      # @see http://redis.io/commands/hlen
      #
      # @param [String] key
      #
      # @return [Integer] number of fields in the hash, or 0 when
      #   key does not exist.
      def hlen(key)
        run(:HLEN, key)
      end

      # Get the field values of all given hash fields
      # @see http://redis.io/commands/hmget
      #
      # @param [String] key under which hash is stored
      # @param [String, Array<String>] fields to get
      #
      # @return [Array] list of values associated with the given fields,
      #   in the same order as they are requested.
      def hmget(key, *fields)
        run(*fields.unshift(:HMGET, key))
      end

      # Set multiple hash fields to multiple values
      # @see http://redis.io/commands/hmset
      #
      # @param [String] key under which store hash
      # @param [[String, String], Array<[String, String]>] args fields and values
      #
      # @return [String] 'OK'
      def hmset(key, *args)
        run(*args.unshift(:HMSET, key))
      end

      # Set the string value of a hash field
      # @see http://redis.io/commands/hset
      #
      # @param [String] key
      # @param [String] field
      # @param [String] value
      #
      # @return [Integer] 1 if field is a new field in the hash and value was set.
      #   0 if field already exists in the hash and the value was updated.
      def hset(key, field, value)
        run(:HSET, key, field, value)
      end

      # Set the value of a hash field, only if the field does not exist
      # @see http://redis.io/commands/hsetnx
      #
      # @param [String] key
      # @param [String] field
      # @param [String] value
      #
      # @return [Integer] 1 if field is a new field in the hash and value was set.
      #   0 if field already exists in the hash and no operation was performed.
      def hsetnx(key, field, value)
        run(:HSETNX, key, field, value)
      end

      # Get the length of the value of a hash field
      # @see http://redis.io/commands/hstrlen
      #
      # @param [String] key
      # @param [String] field
      #
      # @return [Integer] the string length of the value associated with field,
      #   or 0 when field is not present in the hash or key does not exist at all.
      def hstrlen(key, field)
        run(:HSTRLEN, key, field)
      end

      # Get all values in a hash
      # @see http://redis.io/commands/hvals
      #
      # @param [String] key
      #
      # @return [Array] list of values in the hash, or an empty list when
      #   key does not exist
      def hvals(key)
        run(:HVALS, key)
      end
    end
  end
end
