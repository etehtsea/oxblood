require 'oxblood/connection'
require 'oxblood/command'

module Oxblood
  class Session
    def initialize(connection)
      @connection = connection
    end

    #
    # Hashes
    #

    # Removes the specified fields from the hash stored at key
    # @see http://redis.io/commands/hdel
    #
    # @param [String] key under which hash is stored
    # @param [Array<#to_s>] fields to delete
    #
    # @return [Integer] the number of fields that were removed from the hash
    def hdel(key, fields)
      run(cmd.hdel(key, fields))
    end

    # Returns if field is an existing field in the hash stored at key
    # @see http://redis.io/commands/hexists
    #
    # @param [String] key under which hash is stored
    # @param [String] field to check for existence
    #
    # @return [Boolean] do hash contains field or not
    def hexists(key, field)
      1 == run(cmd.hexists(key, field))
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
      run(cmd.hget(key, field))
    end

    # Get all the fields and values in a hash
    # @see http://redis.io/commands/hgetall
    #
    # @param [String] key under which hash is stored
    #
    # @return [Hash] of fields and their values
    def hgetall(key)
      Hash[*run(cmd.hgetall(key))]
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
      run(cmd.hincrby(key, field, increment))
    end

    # Increment the float value of a hash field by the given number
    # @see http://redis.io/commands/hincrby
    #
    # @param [String] key under which hash is stored
    # @param [String] field to increment
    # @param [Integer] increment by value
    #
    # @return [String] the value of field after the increment
    def hincrbyfloat(key, field, increment)
      run(cmd.hincrbyfloat(key, field, increment))
    end

    # Get all the keys in a hash
    # @see http://redis.io/commands/hkeys
    #
    # @param [String] key
    #
    # @return [Array] list of fields in the hash, or an empty list when
    #   key does not exist.
    def hkeys(key)
      run(cmd.hkeys(key))
    end

    # Get the number of keys in a hash
    # @see http://redis.io/commands/hlen
    #
    # @param [String] key
    #
    # @return [Integer] number of fields in the hash, or 0 when
    #   key does not exist.
    def hlen(key)
      run(cmd.hlen(key))
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
      run(cmd.hmget(key, *fields))
    end

    # Set multiple hash fields to multiple values
    # @see http://redis.io/commands/hmset
    #
    # @param [String] key under which store hash
    # @param [[String, String], Array<[String, String]>] args fields and values
    #
    # @return [String] 'OK'
    def hmset(key, *args)
      run(cmd.hmset(key, *args))
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
      run(cmd.hset(key, field, value))
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
      run(cmd.hsetnx(key, field, value))
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
      run(cmd.hstrlen(key, field))
    end

    # Get all values in a hash
    # @see http://redis.io/commands/hvals
    #
    # @param [String] key
    #
    # @return [Array] list of values in the hash, or an empty list when
    #   key does not exist
    def hvals(key)
      run(cmd.hvals(key))
    end

    # Incrementally iterate hash fields and associated values
    # @see http://redis.io/commands/hscan
    #
    # @todo Implement this command
    def hscan(key, cursor)
    end

    # ------------------ Strings ---------------------

    # ------------------ Connection ---------------------

    # Returns PONG if no argument is provided, otherwise return a copy of
    # the argument as a bulk
    # @see http://redis.io/commands/ping
    #
    # @param [String] message to return
    #
    # @return [String] message passed as argument
    def ping(message = nil)
      run(cmd.ping(message))
    end

    # ------------------ Server ---------------------

    # Returns information and statistics about the server in a format that is
    # simple to parse by computers and easy to read by humans
    # @see http://redis.io/commands/info
    #
    # @param [String] section used to select a specific section of information
    def info(section = nil)
      command = [:INFO]
      command << section if section

      response = run(cmd.info(section))
      # FIXME: Parse response
    end

    # ------------------ Keys ------------------------

    # Delete a key
    # @see http://redis.io/commands/del
    #
    # @param [String, Array<String>] keys to delete
    #
    # @return [Integer] the number of keys that were removed
    def del(*keys)
      run(cmd.del(*keys))
    end

    # Find all keys matching the given pattern
    # @see http://redis.io/commands/keys
    #
    # @param [String] pattern used to match keys
    def keys(pattern)
      run(cmd.keys(pattern))
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
      run(cmd.expire(key, seconds))
    end

    # ------------------ Sets ------------------------

    # Add one or more members to a set
    # @see http://redis.io/commands/sadd
    #
    # @param [String] key under which store set
    # @param [String, Array<String>] members to store
    #
    # @return [Integer] the number of elements that were added to the set,
    #   not including all the elements already present into the set.
    def sadd(key, *members)
      run(cmd.sadd(key, *members))
    end

    # Add multiple sets
    # @see http://redis.io/commands/sunion
    #
    # @param [String, Array<String>] keys
    #
    # @return [Array] list with members of the resulting set
    def sunion(*keys)
      run(cmd.sunion(*keys))
    end

    # ------------------ Sorted Sets -----------------

    # Add one or more members to a sorted set, or update its score if it already
    # exists.
    # @see http://redis.io/commands/zadd
    #
    # @todo Add support for zadd options
    #   http://redis.io/commands/zadd#zadd-options-redis-302-or-greater
    #
    # @param [String] key under which store set
    # @param [[Float, String], Array<[Float, String]>] args scores and members
    def zadd(key, *args)
      run(cmd.zadd(key, *args))
    end

    # Return a range of members in a sorted set, by score
    # @see http://redis.io/commands/zrangebyscore
    #
    # @todo Support optional args (WITHSCORES/LIMIT)
    #
    # @param [String] key under which set is stored
    # @param [String] min value
    # @param [String] max value
    def zrangebyscore(key, min, max)
      run(cmd.zrangebyscore(key, min, max))
    end

    protected

    def cmd
      Command
    end

    def run(command)
      @connection.write(command)
      @connection.read_response
    end
  end
end
