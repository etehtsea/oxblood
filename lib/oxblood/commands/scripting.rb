require 'oxblood/commands/scripting'

module Oxblood
  module Commands
    module Scripting
      # Execute a Lua script server side
      # @see https://redis.io/commands/eval
      #
      # @example
      #   session.eval("return redis.call('set','foo','bar')", 0)
      #   # => 'OK'
      #
      # @example
      #   session.eval("return redis.call('set',KEYS[1],'bar')", 1, :foo)
      #   # => 'OK'
      #
      # @example
      #   session.eval("return 10", 0)
      #   # => 10
      #
      # @example
      #   session.eval("return {1,2,{3,'Hello World!'}}", 0)
      #   # => [1, 2, [3, 'Hello World!']]
      #
      # @example
      #   session.eval("return redis.call('get','foo')", 0)
      #   # => 'bar'
      #
      # @example
      #   session.eval("return {1,2,3.3333,'foo',nil,'bar'}", 0)
      #   # => [1, 2, 3, 'foo']
      #
      # @param [String] script
      # @param [Integer] numkeys
      # @param [String, Array<String>] keys_and_args
      def eval(script, numkeys, *keys_and_args)
        run(:EVAL, script, numkeys, keys_and_args)
      end

      # Execute a Lua script server side
      # @see https://redis.io/commands/evalsha
      #
      # @param [String] sha1
      # @param [Integer] numkeys
      # @param [String, Array<String>] keys_and_args
      def evalsha(sha1, numkeys, *keys_and_args)
        run(:EVALSHA, sha1, numkeys, keys_and_args)
      end

      # Set the debug mode for executed scripts.
      # @see https://redis.io/commands/script-debug
      #
      # @param [Symbol] mode
      #
      # @return [String] 'OK'
      # @return [RError] if wrong mode passed
      def script_debug(mode)
        run(:SCRIPT, :DEBUG, mode)
      end

      # Check existence of scripts in the script cache.
      # @see https://redis.io/commands/script-exists
      #
      # @param [String, Array<String>] sha1_digests
      #
      # @return [Array<Integer>] For every corresponding SHA1 digest of a script
      #   that actually exists in the script cache, an 1 is returned,
      #   otherwise 0 is returned.
      def script_exists(*sha1_digests)
        run(*sha1_digests.unshift(:SCRIPT, :EXISTS))
      end

      # Remove all the scripts from the script cache.
      # @see https://redis.io/commands/script-flush
      #
      # @return [String] 'OK'
      def script_flush
        run(:SCRIPT, :FLUSH)
      end

      # Kill the script currently in execution.
      # @see https://redis.io/commands/script-kill
      #
      # @return [String] 'OK'
      # @return [RError] if there is no script to kill
      def script_kill
        run(:SCRIPT, :KILL)
      end

      # Load the specified Lua script into the script cache.
      # @see https://redis.io/commands/script-load
      #
      # @param [String] script
      #
      # @return [String] This command returns the SHA1 digest of the script
      #   added into the script cache
      def script_load(script)
        run(:SCRIPT, :LOAD, script)
      end
    end
  end
end
