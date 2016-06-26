module Oxblood
  module Command
    class << self
      #
      # Hashes
      #

      def hdel(key, fields)
        serialize([:HDEL, key, fields])
      end

      def hexists(key, field)
        serialize([:HEXISTS, key, field])
      end

      def hget(key, field)
        serialize([:HGET, key, field])
      end

      def hgetall(key)
        serialize([:HGETALL, key])
      end

      def hincrby(key, field, increment)
        serialize([:HINCRBY, key, field, increment])
      end

      def hincrbyfloat(key, field, increment)
        serialize([:HINCRBYFLOAT, key, field, increment])
      end

      def hkeys(key)
        serialize([:HKEYS, key])
      end

      def hlen(key)
        serialize([:HLEN, key])
      end

      def hmget(key, *fields)
        serialize(fields.unshift(:HMGET, key))
      end

      def hmset(key, *args)
        serialize(args.unshift(:HMSET, key))
      end

      def hset(key, field, value)
        serialize([:HSET, key, field, value])
      end

      def hsetnx(key, field, value)
        serialize([:HSETNX, key, field, value])
      end

      def hstrlen(key, field)
        serialize([:HSTRLEN, key, field])
      end

      def hvals(key)
        serialize([:HVALS, key])
      end

      def hscan(_key, _cursor)
        raise 'Not implemented!'
      end

      # ------------------ Strings ---------------------

      # ------------------ Connection ---------------------

      def ping(message = nil)
        command = [:PING]
        command << message if message

        serialize(command)
      end

      def select(index)
        serialize([:SELECT, index])
      end

      # ------------------ Server ---------------------

      def info(section = nil)
        command = [:INFO]
        command << section if section

        serialize(command)
      end

      # ------------------ Keys ------------------------

      def del(*keys)
        serialize(keys.unshift(:DEL))
      end

      def keys(pattern)
        serialize([:KEYS, pattern])
      end

      def expire(key, seconds)
        serialize([:EXPIRE, key, seconds])
      end

      # ------------------ Sets ------------------------

      def sadd(key, *members)
        serialize(members.unshift(:SADD, key))
      end

      def sunion(*keys)
        serialize(keys.unshift(:SUNION))
      end

      # ------------------ Sorted Sets -----------------

      def zadd(key, *args)
        serialize(args.unshift(:ZADD, key))
      end

      # @todo Support optional args (WITHSCORES/LIMIT)
      def zrangebyscore(key, min, max)
        serialize([:ZRANGEBYSCORE, key, min, max])
      end

      private

      def serialize(command)
        Protocol.build_command(command)
      end
    end
  end
end
