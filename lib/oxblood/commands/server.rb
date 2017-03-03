module Oxblood
  module Commands
    module Server
      # Asynchronously rewrite the append-only file.
      # @see https://redis.io/commands/bgrewriteaof
      #
      # @return [String] always 'OK'
      def bgrewriteaof
        run(:BGREWRITEAOF)
      end

      # Asynchronously save the dataset to disk
      # @see https://redis.io/commands/bgsave
      #
      # @return [String] command status message
      def bgsave
        run(:BGSAVE)
      end

      # Get the current conneciton name.
      # @see https://redis.io/commands/client-getname
      #
      # @return [nil, String] client name
      def client_getname
        run(:CLIENT, :GETNAME)
      end

      # Get the list of client connections.
      # @see https://redis.io/commands/client-list
      #
      # @return [String] client list in the formatted string
      def client_list
        run(:CLIENT, :LIST)
      end

      # Kill the connection of a client.
      # @see https://redis.io/commands/client-kill
      #
      # @param [Hash, String] opts_or_addr hash of options or addr in
      #   an addr:port form.
      #
      # @option opts_or_addr [Integer] :id unique client ID.
      # @option opts_or_addr [Symbol] :type Close connections of all the clients
      #   of specified type (for example: `normal`, `master`, `slave`, `pubsub`).
      # @option opts_or_addr [String] :addr ip:port which matches a line
      #   returned by CLIENT LIST command (addr field).
      # @option opts_or_addr [Boolean] :skipme Skip client that is calling this
      #   command (enabled by default).
      #
      # @return [String] 'OK'
      # @return [Integer] the number of clients killed when called with
      #   the filter/value format
      def client_kill(opts_or_addr = {})
        if opts_or_addr.is_a?(String)
          run(:CLIENT, :KILL, opts_or_addr)
        else
          args = [:CLIENT, :KILL]

          if v = opts_or_addr[:id]
            args.push(:ID, v)
          end

          if v = opts_or_addr[:type]
            args.push(:TYPE, v)
          end

          if v = opts_or_addr[:addr]
            args.push(:ADDR, v)
          end

          if opts_or_addr.key?(:skipme)
            case opts_or_addr[:skipme]
            when false, 'no'.freeze
              args.push(:SKIPME, 'no'.freeze)
            when true, 'yes'.freeze
              args.push(:SKIPME, 'yes'.freeze)
            end
          end

          run(*args)
        end
      end

      # Set the current connection name.
      # @see https://redis.io/commands/client-setname
      #
      # @param [String] connection_name
      #
      # @return [String] 'OK' in case of success.
      def client_setname(connection_name)
        run(:CLIENT, :SETNAME, connection_name)
      end

      # Stop processing commands from clients for some time.
      # @see https://redis.io/commands/client-pause
      #
      # @param [Integer] timeout in milliseconds
      #
      # @return [String] 'OK' in case of success.
      def client_pause(timeout)
        run(:CLIENT, :PAUSE, timeout)
      end

      # Get array of Redis command details.
      # @see https://redis.io/commands/command
      #
      # @return [Array] nested list of command details
      def command
        run(:COMMAND)
      end

      # Get total number of Redis commands.
      # @see https://redis.io/commands/command-count
      #
      # @return [Integer] number of commands returned by COMMAND
      def command_count
        run(:COMMAND, :COUNT)
      end

      # Extract keys given a full Redis command
      # @see https://redis.io/commands/command-getkeys
      #
      # @return [Array] list of keys from your command
      def command_getkeys(*args)
        run(*args.unshift(:COMMAND, :GETKEYS))
      end

      # Get array of specific Redis command details.
      # @see https://redis.io/commands/command-info
      #
      # @param [String, Array<String>] command_names
      #
      # @return [Array] nested list of command details.
      def command_info(*command_names)
        run(*command_names.unshift(:COMMAND, :INFO))
      end

      # Get the value of a configuration parameter
      # @see https://redis.io/commands/config-get
      #
      # @param [String] parameter
      #
      # @return [Array] parameters with values
      def config_get(parameter)
        run(:CONFIG, :GET, parameter)
      end

      # Rewrite the configuration file with the in memory configuration
      # @see https://redis.io/commands/config-rewrite
      #
      # @return [String] 'OK'
      def config_rewrite
        run(:CONFIG, :REWRITE)
      end

      # Set a configuration parameter to the given value
      # @see https://redis.io/commands/config-set
      #
      # @param [String] parameter
      # @param [String] value
      #
      # @return [String] OK if parameter was set properly.
      def config_set(parameter, value)
        run(:CONFIG, :SET, parameter, value)
      end

      # Reset the stats returned by INFO
      # @see https://redis.io/commands/config-resetstat
      #
      # @return [String] 'OK'
      def config_resetstat
        run(:CONFIG, :RESETSTAT)
      end

      # Return the number of keys in the selected database
      # @see https://redis.io/commands/dbsize
      #
      # @return [Integer] selected database size
      def dbsize
        run(:DBSIZE)
      end

      # Remove all keys from all databases.
      # @see https://redis.io/commands/flushall
      #
      # @param [Hash] opts
      #
      # @option opts [Boolean] :async
      #
      # @return [String] 'OK'
      def flushall(opts = {})
        opts[:async] ? run(:FLUSHALL, :ASYNC) : run(:FLUSHALL)
      end

      # Remove all keys from the current database.
      # @see http://redis.io/commands/flushdb
      #
      # @param [Hash] opts
      #
      # @option opts [Boolean] :async
      #
      # @return [String] should always return 'OK'
      def flushdb(opts = {})
        opts[:async] ? run(:FLUSHDB, :ASYNC) : run(:FLUSHDB)
      end

      # Returns information and statistics about the server in a format that is
      # simple to parse by computers and easy to read by humans.
      # @see http://redis.io/commands/info
      #
      # @param [String] section used to select a specific section of information
      #
      # @return [String] raw redis server response as a collection of text lines.
      def info(section = nil)
        section ? run(:INFO, section) : run(:INFO)
      end

      # Get the UNIX timestamp of the last successful save to disk.
      # @see https://redis.io/commands/lastsave
      #
      # @return [Integer] an UNIX timestamp.
      def lastsave
        run(:LASTSAVE)
      end

      # Return the role of the instance in the context of replication.
      # @see https://redis.io/commands/role
      #
      # @return [Array] where the first element is one of master, slave,
      #   sentinel and the additional elements are role-specific as illustrated
      #   above.
      def role
        run(:ROLE)
      end

      # Synchronously save the dataset to disk.
      # @see https://redis.io/commands/save
      #
      # @return [String] 'OK'
      def save
        run(:SAVE)
      end

      # Synchronously save the dataset to disk and then shutdown the server.
      # @see https://redis.io/commands/shutdown
      #
      # @param [Hash] opts
      #
      # @option opts [Boolean] :save truthy value acts as SAVE and explicit
      #   `false` value acts as NOSAVE. `nil` or absence of option don't add anything.
      #
      # @return [RError] in case of failure and nothing
      # @return [nil] in case of success
      def shutdown(opts = {})
        case opts[:save]
        when nil
          run(:SHUTDOWN)
        when false
          run(:SHUTDOWN, :NOSAVE)
        else
          run(:SHUTDOWN, :SAVE)
        end
      rescue Errno::ECONNRESET
        nil
      end

      # Make the server a slave of another instance, or promote it as master.
      # @see https://redis.io/commands/slaveof
      #
      # @example Make server slave
      #   session.slaveof('localhost', 7777)
      # @example Promote to master
      #   session.slaveof(:NO, :ONE)
      #
      # @param [String] host
      # @param [String] port
      #
      # @return [String] 'OK'
      def slaveof(host, port)
        run(:SLAVEOF, host, port)
      end

      # Manages the Redis slow queries log.
      # @see https://redis.io/commands/slowlog
      #
      # @param [Symbol] subcommand For example :len, :reset, :get
      # @param [String] argument
      #
      # @return [Integer] for :len subcommand
      # @return [String] 'OK' for :reset subcommand
      # @return [Array] for :get subcommand
      def slowlog(subcommand, argument = nil)
        args = [:SLOWLOG, subcommand]
        args << argument if argument
        run(*args)
      end

      # Returns the current server time.
      # @see https://redis.io/commands/time
      #
      # @return [Array<String, String>] unix time in seconds and microseconds.
      def time
        run(:TIME)
      end
    end
  end
end
