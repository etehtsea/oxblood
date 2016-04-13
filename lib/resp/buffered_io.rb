module RESP
  # @private
  class BufferedIO
    def initialize(socket)
      @socket = socket
      @buffer = String.new
    end

    def gets(separator, timeout)
      crlf = nil

      while (crlf = @buffer.index(separator)) == nil
        @buffer << _read_from_socket(1024, timeout)
      end

      @buffer.slice!(0, crlf + separator.bytesize)
    end

    def read(nbytes, timeout)
      result = @buffer.slice!(0, nbytes)

      while result.bytesize < nbytes
        result << _read_from_socket(nbytes - result.bytesize, timeout)
      end

      result
    end

    private

    def _read_from_socket(nbytes, timeout)
      begin
        @socket.read_nonblock(nbytes)
      rescue Errno::EWOULDBLOCK, Errno::EAGAIN
        if IO.select([@socket], nil, nil, timeout)
          retry
        else
          raise Connection::TimeoutError
        end
      end

    rescue EOFError
      raise Errno::ECONNRESET
    end
  end
end
