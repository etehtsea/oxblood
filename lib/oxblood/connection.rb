require 'oxblood/protocol'
require 'oxblood/buffered_io'

module Oxblood
  # Class responsible for connection maintenance
  class Connection
    TimeoutError = Class.new(RuntimeError)

    class << self
      # Open Redis connection
      #
      # @param [Hash] options Connection options
      #
      # @option (see .connect_tcp)
      # @option (see .connect_unix)
      def open(options = {})
        options.key?(:path) ? connect_unix(options) : connect_tcp(options)
      end

      # Connect to Redis server through TCP
      #
      # @param [Hash] options Connection options
      #
      # @option options [String] :host ('localhost') Hostname or IP address to connect to
      # @option options [Integer] :port (5672) Port Redis server listens on
      # @option options [Float] :timeout (1.0) socket read timeout
      # @option options [Float] :connect_timeout (1.0) socket connect timeout
      #
      # @return [Oxblood::Connection] connection instance
      def connect_tcp(options = {})
        host = options.fetch(:host, 'localhost')
        port = options.fetch(:port, 6379)
        timeout = options.fetch(:timeout, 1.0)
        connect_timeout = options.fetch(:connect_timeout, 1.0)

        socket = Socket.tcp(host, port, connect_timeout: connect_timeout)
        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        new(socket, timeout)
      end

      # Connect to Redis server through UNIX socket
      #
      # @param [Hash] options Connection options
      #
      # @option options [String] :path UNIX socket path
      # @option options [Float] :timeout (1.0) socket read timeout
      #
      # @raise [KeyError] if :path was not passed
      #
      # @return [Oxblood::Connection] connection instance
      def connect_unix(options = {})
        path = options.fetch(:path)
        timeout = options.fetch(:timeout, 1.0)

        socket = ::Socket.unix(path)
        new(socket, timeout)
      end
    end

    def initialize(socket, timeout)
      @socket = socket
      @timeout = timeout
      @buffer = BufferedIO.new(socket)
    end

    # Send comand to Redis server
    # @example send_command(['CONFIG', 'GET', '*']) => 32
    # @param [Array] command Array of command name with it's args
    # @return [Integer] Number of bytes written to socket
    def send_command(command)
      write(Protocol.build_command(command))
    end

    # FIXME: docs
    def write(command)
      @socket.write(command)
    end

    # Send command to Redis server and read response from it
    # @example run_command(['PING']) => PONG
    # @param [Array] command Array of command name with it's args
    # @return #FIXME
    def run_command(command)
      send_command(command)
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

    # FIXME: docs
    def read_responses(n)
      Array.new(n) { read_response }
    end
  end
end
