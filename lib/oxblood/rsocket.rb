require 'io/wait'
require 'socket'

module Oxblood
  # Thin socket wrapper made with resilience. Socket will be closed and
  # automatically recreated in case of any errors (including timeout errors)
  # in order to avoid inconsistent state.
  class RSocket
    TimeoutError = Class.new(RuntimeError)

    # JRuby before 9.1.6.0 don't properly support SO_LINGER setting
    # @see https://github.com/jruby/jruby/issues/4040
    LINGER_OPTION = if RUBY_ENGINE == 'jruby' &&
                       Gem::Version.new(JRUBY_VERSION) < Gem::Version.new('9.1.6.0')
                      [Socket::SOL_SOCKET, :LINGER, 0].freeze
                    else
                      Socket::Option.linger(true, 0)
                    end
    private_constant :LINGER_OPTION

    # @!attribute [rw] timeout
    #   @return [Numeric] timeout in seconds
    attr_accessor :timeout

    # Maintain socket
    #
    # @param [Hash] opts Connection options
    #
    # @option opts [Float] :timeout (1.0) socket read/write timeout
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
    def read(nbytes, timeout = @timeout)
      result = @buffer.slice!(0, nbytes)

      while result.bytesize < nbytes
        result << readpartial(nbytes - result.bytesize, timeout)
      end

      result
    end

    # Read until separator
    # @param [String] separator separator
    # @return [String] read result
    def gets(separator, timeout = @timeout)
      while (crlf = @buffer.index(separator)).nil?
        @buffer << readpartial(1024, timeout)
      end

      @buffer.slice!(0, crlf + separator.bytesize)
    end

    # Write data to socket
    # @param [String] data given
    # @return [Integer] the number of bytes written
    def write(data, timeout = @timeout)
      full_size = data.bytesize

      while data.bytesize > 0
        written = socket.write_nonblock(data, exception: false)

        if written == :wait_writable
          socket.wait_writable(timeout) or fail_with_timeout!
        else
          data = data.byteslice(written..-1)
        end
      end

      full_size
    end

    # Close connection to server
    # @return [nil] always return nil
    def close
      @buffer.clear
      @socket && @socket.close
    rescue IOError
      ;
    ensure
      @socket = nil
    end

    # True if socket exists
    # @return [Boolean] socket exists or not
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

    def readpartial(nbytes, timeout)
      case data = socket.read_nonblock(nbytes, exception: false)
      when String
        return data
      when :wait_readable
        socket.wait_readable(timeout) or fail_with_timeout!
      when nil
        close
        raise Errno::ECONNRESET
      end while true
    end


    def fail_with_timeout!
      # In case of failure close socket ASAP
      socket.setsockopt(*LINGER_OPTION)
      close
      raise TimeoutError
    end
  end
end
