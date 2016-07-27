require 'socket'

module Oxblood
  # Thin socket wrapper made with resilience. Socket will be closed and
  # automatically recreated in case of any errors (including timeout errors)
  # in order to avoid inconsistent state.
  class RSocket
    TimeoutError = Class.new(RuntimeError)

    # @!attribute [rw] timeout
    #   @return [Numeric] timeout in seconds
    attr_accessor :timeout

    # Maintain socket
    #
    # @param [Hash] opts Connection options
    #
    # @option opts [Float] :timeout (1.0) socket read timeout
    #
    # @option opts [String] :host ('localhost') Hostname or IP address to connect to
    # @option opts [Integer] :port (6379) Port Redis server listens on
    # @option opts [Float] :connect_timeout (1.0) socket connect timeout
    #
    # @option opts [String] :path UNIX socket path
    def initialize(opts = {})
      @opts = opts
      @timeout = opts.fetch(:timeout, 1.0)
      @socket = create_socket(opts)
      @buffer = String.new.encode!('ASCII-8BIT')
    end

    # Read number of bytes
    # @param [Integer] nbytes number of bytes to read
    # @return [String] read result
    def read(nbytes)
      result = @buffer.slice!(0, nbytes)

      while result.bytesize < nbytes
        result << readpartial(nbytes - result.bytesize)
      end

      result
    end

    # Read until separator
    # @param [String] separator separator
    # @return [String] read result
    def gets(separator)
      while (crlf = @buffer.index(separator)).nil?
        @buffer << readpartial(1024)
      end

      @buffer.slice!(0, crlf + separator.bytesize)
    end

    # Write data to socket
    # @param [#to_s] data given
    # @return [Integer] the number of bytes written
    def write(data)
      socket.write(data)
    end

    # Close connection to server
    # @return [nil] always return nil
    def close
      @buffer.clear
      socket.close
    rescue IOError
      ;
    ensure
      @socket = nil
    end

    # True if connection is established
    # @return [Boolean] connection status
    def connected?
      !!@socket
    end

    private

    def socket
      @socket ||= create_socket(@opts)
    end

    def create_socket(opts)
      if opts.key?(:path)
        UNIXSocket.new(opts.fetch(:path))
      else
        host = opts.fetch(:host, 'localhost')
        port = opts.fetch(:port, 6379)
        connect_timeout = opts.fetch(:connect_timeout, 1.0)

        Socket.tcp(host, port, connect_timeout: connect_timeout).tap do |sock|
          sock.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
        end
      end
    end

    def readpartial(nbytes)
      begin
        socket.read_nonblock(nbytes)
      rescue IO::WaitReadable, Errno::EINTR
        if IO.select([socket], nil, nil, @timeout)
          retry
        else
          close
          raise TimeoutError
        end
      end
    rescue EOFError
      close
      raise Errno::ECONNRESET
    end
  end
end
