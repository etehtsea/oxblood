require 'socket'
require 'oxblood/protocol'
require 'oxblood/buffered_io'
require 'oxblood/session'

module Oxblood
  # Class responsible for connection maintenance
  class Connection
    TimeoutError = Class.new(RuntimeError)

    class << self
      # Open connection to Redis server
      #
      # @param [Hash] opts Connection options
      #
      # @option opts [Float] :timeout (1.0) socket read timeout
      # @option opts [Integer] :db database number
      # @option opts [String] :password
      #
      # @option opts [String] :host ('localhost') Hostname or IP address to connect to
      # @option opts [Integer] :port (6379) Port Redis server listens on
      # @option opts [Float] :connect_timeout (1.0) socket connect timeout
      #
      # @option opts [String] :path UNIX socket path
      #
      # @return [Oxblood::Connection] connection instance
      def open(opts = {})
        socket = if opts.key?(:path)
                   unix_socket(opts.fetch(:path))
                 else
                   host = opts.fetch(:host, 'localhost')
                   port = opts.fetch(:port, 6379)
                   connect_timeout = opts.fetch(:connect_timeout, 1.0)

                   tcp_socket(host, port, connect_timeout)
                 end

        timeout = opts.fetch(:timeout, 1.0)

        new(socket, timeout).tap do |conn|
          session = Session.new(conn)
          session.auth!(opts[:password]) if opts[:password]
          session.select(opts[:db]) if opts[:db]
        end
      end

      private

      def unix_socket(path)
        UNIXSocket.new(path)
      end

      def tcp_socket(host, port, connect_timeout)
        Socket.tcp(host, port, connect_timeout: connect_timeout).tap do |sock|
          sock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        end
      end
    end

    def initialize(socket, timeout)
      @socket = socket
      @timeout = timeout
      @buffer = BufferedIO.new(socket)
    end

    # Send comand to Redis server
    # @example send_command('CONFIG', 'GET', '*') => 32
    # @param [Array] command Array of command name with it's args
    # @return [Integer] Number of bytes written to socket
    def send_command(*command)
      write(Protocol.build_command(*command))
    end

    # Write data to socket
    # @param [#to_s] data given
    # @return [Integer] the number of bytes written
    def write(data)
      @socket.write(data)
    end

    # Send command to Redis server and read response from it
    # @example run_command('PING') => PONG
    # @param [Array] command Array of command name with it's args
    def run_command(*command)
      send_command(*command)
      read_response
    end

    # True if connection is established
    # @return [Boolean] connection status
    def connected?
      !!@socket
    end

    # Close connection to server
    def close
      @socket.close
    ensure
      @socket = nil
    end

    # Read number of bytes
    # @param [Integer] nbytes number of bytes to read
    # @return [String] read result
    def read(nbytes)
      @buffer.read(nbytes, @timeout)
    end

    # Read until separator
    # @param [String] sep separator
    # @return [String] read result
    def gets(sep)
      @buffer.gets(sep, @timeout)
    end

    # Set new read timeout
    # @param [Float] timeout new timeout
    def timeout=(timeout)
      @timeout = timeout
    end

    # Read response from server
    # @raise [TimeoutError] if timeout happen
    # @note Will raise TimeoutError even if there is simply no response to read
    #       from server. For example, if you are trying to read response before
    #       sending command.
    # @todo Raise specific error if server has nothing to answer.
    def read_response
      Protocol.parse(self)
    end

    # Read several responses from server
    # (see #read_response)
    def read_responses(n)
      Array.new(n) { read_response }
    end
  end
end
