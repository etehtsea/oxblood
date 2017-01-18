module Oxblood
  module Commands
    module Keys
      # Delete a key
      # @see http://redis.io/commands/del
      #
      # @param [String, Array<String>] keys to delete
      #
      # @return [Integer] the number of keys that were removed
      def del(*keys)
        run(*keys.unshift(:DEL))
      end

      # Return a serialized version of the value stored at specified key.
      # @see http://redis.io/commands/dump
      #
      # @param [String] key
      #
      # @return [String] serialized value
      def dump(key)
        run(:DUMP, key)
      end

      # Determine if a key exists
      # @see http://redis.io/commands/exists
      #
      # @param [String, Array<String>] keys to check
      #
      # @return [Integer] the number of keys existing among the ones specified as
      #   arguments. Keys mentioned multiple times and existing are counted
      #   multiple times.
      def exists(*keys)
        run(*keys.unshift(:EXISTS))
      end

      # Set a key's time to live in seconds
      # @see http://redis.io/commands/expire
      #
      # @param [String] key to expire
      # @param [Integer] seconds number of seconds
      #
      # @return [Integer] 1 if the timeout was set. 0 if key does not exist or
      #   the timeout could not be set.
      def expire(key, seconds)
        run(:EXPIRE, key, seconds)
      end

      # Set the expiration for a key as a UNIX timestamp
      # @see http://redis.io/commands/expireat
      #
      # @param [String] key
      # @param [Integer] timestamp in UNIX format
      #
      # @return [Integer] 1 if the timeout was set. 0 if key does not exist or
      #   the timeout could not be set.
      def expireat(key, timestamp)
        run(:EXPIREAT, key, timestamp)
      end

      # Find all keys matching the given pattern
      # @see http://redis.io/commands/keys
      #
      # @param [String] pattern used to match keys
      def keys(pattern)
        run(:KEYS, pattern)
      end

      # Move a key to another database
      # @see http://redis.io/commands/move
      #
      # @param [String] key
      # @param [Integer] db index
      #
      # @return [Integer] 1 if key was moved and 0 otherwise.
      def move(key, db)
        run(:MOVE, key, db)
      end

      # Inspect the internals of Redis objects
      # @see http://redis.io/commands/object
      #
      # @param [String] subcommand `REFCOUNT`, `ENCODING`, `IDLETIME`
      # @param [String] key
      #
      # @return [Integer] in case of `REFCOUNT` and `IDLETIME` subcommands
      # @return [String] in case of `ENCODING` subcommand
      # @return [nil] if object you try to inspect is missing
      def object(subcommand, key)
        run(:OBJECT, subcommand, key)
      end

      # Remove expiration from a key
      # @see http://redis.io/commands/persist
      # @param [String] key
      #
      # @return [Integer] 1 if the timeout was removed and 0 otherwise
      def persist(key)
        run(:PERSIST, key)
      end

      # Set a key's time to live in milliseconds
      # @see http://redis.io/commands/pexpire
      #
      # @param [String] key
      # @param [Integer] milliseconds
      #
      # @return [Integer] 1 if the timeout was set and 0 otherwise
      def pexpire(key, milliseconds)
        run(:PEXPIRE, key, milliseconds)
      end

      # Set the expiration for a key as a UNIX timestamp specified in milliseconds
      # @see http://redis.io/commands/pexpireat
      #
      # @param [String] key
      # @param [Integer] timestamp in milliseconds
      #
      # @return [Integer] 1 if the timeout was set and 0 otherwise
      def pexpireat(key, timestamp)
        run(:PEXPIREAT, key, timestamp)
      end

      # Get the time to live for a key in milliseconds
      # @see http://redis.io/commands/pttl
      #
      # @param [String] key
      #
      # @return [Integer] TTL in milliseconds, or a negative value in order to
      #   signal an error
      def pttl(key)
        run(:PTTL, key)
      end

      # Return a random key from the keyspace
      # @see http://redis.io/commands/randomkey
      #
      # @return [String] the random key
      # @return [nil] if database is empty
      def randomkey
        run(:RANDOMKEY)
      end

      # Rename a key
      # @see http://redis.io/commands/rename
      #
      # @param [String] key to rename
      # @param [String] newkey
      #
      # @return [String] OK in case of success
      # @return [RError] if key does not exist. Before Redis 3.2.0, an error is
      #   returned if source and destination names are the same.
      def rename(key, newkey)
        run(:RENAME, key, newkey)
      end

      # Rename a key, only if the new key does not exist
      # @see http://redis.io/commands/renamenx
      #
      # @param [String] key to rename
      # @param [String] newkey
      #
      # @return [Integer] 1 if key was renamed to newkey. 0 if newkey already
      #   exists.
      # @return [RError] if key does not exist. Before Redis 3.2.0, an error is
      #   returned if source and destination names are the same.
      def renamenx(key, newkey)
        run(:RENAMENX, key, newkey)
      end

      # Create a key using the provided serialized value, previously obtained
      # using DUMP
      # @see http://redis.io/commands/restore
      #
      # @param [String] key
      # @param [Integer] ttl expire time in milliseconds
      # @param [String] serialized_value obtained using DUMP command
      # @param [Hash] opts
      #
      # @option opts [Boolean] :replace (false) Override key if it already exists
      #
      # @return [String] OK on success
      # @return [RError] if replace is false and key already exists or RDB version
      #   and data checksum don't match.
      def restore(key, ttl, serialized_value, opts = {})
        args = [:RESTORE, key, ttl, serialized_value]
        args << :REPLACE if opts[:replace]

        run(*args)
      end

      # Get the time to live for a key
      # @see http://redis.io/commands/ttl
      #
      # @param [String] key
      #
      # @return [Integer] TTL in seconds, or a negative value in order to signal
      #   an error
      def ttl(key)
        run(:TTL, key)
      end

      # Determine the type stored at key
      # @see http://redis.io/commands/type
      #
      # @param [String] key
      #
      # @return [String] type of key, or none when key does not exist.
      def type(key)
        run(:TYPE, key)
      end

      # Incrementally iterate the keys space
      # @see https://redis.io/commands/scan
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
      def scan(cursor, opts = {})
        args = [:SCAN, cursor]

        if v = opts[:count]
          args.push(:COUNT, v)
        end

        if v = opts[:match]
          args.push(:MATCH, v)
        end

        run(*args)
      end
    end
  end
end
