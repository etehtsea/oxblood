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
      run(:HDEL, key, fields)
    end

    # Returns if field is an existing field in the hash stored at key
    # @see http://redis.io/commands/hexists
    #
    # @param [String] key under which hash is stored
    # @param [String] field to check for existence
    #
    # @return [Boolean] do hash contains field or not
    def hexists(key, field)
      1 == run(:HEXISTS, key, field)
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
    # @return [Hash] of fields and their values
    def hgetall(key)
      Hash[*run(:HGETALL, key)]
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

    # ------------------ Strings ---------------------

    # ------------------ Connection ---------------------

    # Authenticate to the server
    # @see http://redis.io/commands/auth
    #
    # @param [String] password
    #
    # @return [String] 'OK'
    # @return [RError] if wrong password was passed or server does not require
    #   password
    def auth(password)
      run(:AUTH, password)
    end

    # Echo the given string
    # @see http://redis.io/commands/echo
    #
    # @param [String] message
    #
    # @return [String] given string
    def echo(message)
      run(:ECHO, message)
    end

    # Like {#auth}, except that if error returned, raises it.
    #
    # @param [String] password
    #
    # @raise [Protocol::RError] if error returned
    #
    # @return [String] 'OK'
    def auth!(password)
      response = auth(password)
      error?(response) ? (raise response) : response
    end

    # Returns PONG if no argument is provided, otherwise return a copy of
    # the argument as a bulk
    # @see http://redis.io/commands/ping
    #
    # @param [String] message to return
    #
    # @return [String] message passed as argument
    def ping(message = nil)
      message ? run(:PING, message) : run(:PING)
    end

    # Change the selected database for the current connection
    # @see http://redis.io/commands/select
    #
    # @param [Integer] index database to switch
    #
    # @return [String] 'OK'
    # @return [RError] if wrong index was passed
    def select(index)
      run(:SELECT, index)
    end

    # ------------------ Server ---------------------

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

    # ------------------ Keys ------------------------

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
      run(*members.unshift(:SADD, key))
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
    #
    # @return [Integer] The number of elements added to the sorted sets, not
    #   including elements already existing for which the score was updated
    def zadd(key, *args)
      run(*args.unshift(:ZADD, key))
    end

    # Return a range of members in a sorted set, by score
    # @see http://redis.io/commands/zrangebyscore
    #
    # @todo Support optional args (WITHSCORES/LIMIT)
    #
    # @param [String] key under which set is stored
    # @param [String] min value
    # @param [String] max value
    #
    # @return [Array] list of elements in the specified score range
    def zrangebyscore(key, min, max)
      run(:ZRANGEBYSCORE, key, min, max)
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

    protected

    def serialize(*command)
      Protocol.build_command(*command)
    end

    def run(*command)
      @connection.write(serialize(*command))
      @connection.read_response
    end

    private

    def error?(response)
      Protocol::RError === response
    end
  end
end
