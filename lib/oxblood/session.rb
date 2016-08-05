module Oxblood
  # Implements usual Request/Response protocol
  #
  # @note {Session} don't maintain threadsafety! In multithreaded environment
  #   please use {Pool}
  #
  # @example
  #   conn = Oxblood::Connection.new
  #   session = Oxblood::Session.new(conn)
  #   session.ping # => 'PONG'
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

    #
    # Strings
    #

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

    #
    # Connection
    #

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

    # Close the connection
    # @see http://redis.io/commands/quit
    #
    # @return [String] 'OK'
    def quit
      run(:QUIT)
    ensure
      @connection.socket.close
    end

    #
    # Server
    #

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

    #
    # Keys
    #

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

    #
    # Lists
    #

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

    #
    # Sets
    #

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

    #
    # Sorted Sets
    #

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

    protected

    def serialize(*command)
      Protocol.build_command(*command)
    end

    def run(*command)
      @connection.run_command(*command)
    end

    private

    def error?(response)
      Protocol::RError === response
    end
  end
end
