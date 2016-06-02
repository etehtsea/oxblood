require 'connection_pool'
require 'resp/session'
require 'resp/pipeline'

module RESP
  class Pool
    # Initialize connection pool
    #
    # @param [Hash] options Connection options
    #
    # @option options [Float] :timeout (1.0) Connection acquisition timeout.
    # @option options [Integer] :size Pool size.
    # @option options [Hash] :connection see {Connection.open}
    def initialize(options = {})
      timeout = options.fetch(:timeout, 1.0)
      size = options.fetch(:size)

      @pool = ConnectionPool.new(size: size, timeout: timeout) do
        Connection.open(options.fetch(:connection, {}))
      end
    end

    def with
      conn = @pool.checkout
      yield Session.new(conn)
    ensure
      @pool.checkin if conn
    end

    def pipelined
      conn = @pool.checkout
      pipeline = Pipeline.new(conn)
      yield pipeline
      pipeline.sync
    ensure
      @pool.checkin if conn
    end
  end
end
