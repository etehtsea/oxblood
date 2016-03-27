require 'resp/protocol'
require 'resp/buffered_io'

module RESP
  class Connection
    attr_reader :socket

    def self.connect_tcp(host, port, timeout, connect_timeout)
      socket = Socket.tcp(host, port, connect_timeout: connect_timeout)
      socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

      new(socket, timeout)
    end

    def self.connect_unix(path, timeout, _)
      socket = ::Socket.unix(path)
      new(socket, timeout)
    end

    def initialize(socket, timeout)
      @socket = socket
      @timeout = timeout
      @buffer = BufferedIO.new(socket)
    end

    def send_command(command)
      @socket.write(RESP::Protocol.build_command(command))
    end

    def connected?
      !!@socket
    end

    def close
      @socket.close
    ensure
      @socket = nil
    end

    def read(nbytes)
      @buffer.read(nbytes, @timeout)
    end

    def gets(sep)
      @buffer.gets(sep, @timeout)
    end

    def timeout=(timeout)
      @timeout = timeout
    end

    def read_response
      RESP::Protocol.parse(self)
    end
  end
end
