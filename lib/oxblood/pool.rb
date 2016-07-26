require 'connection_pool'
require 'oxblood/session'
require 'oxblood/pipeline'
require 'oxblood/connection'

module Oxblood
  # Create connection pool. For the most use cases this is entrypoint API.
  #
  # @example
  #   pool = Oxblood::Pool.new(size: 8)
  #   pool.with { |c| c.ping } # => 'PONG'
  class Pool
    # Initialize connection pool
    #
    # @param [Hash] options Connection options
    #
    # @option options [Float] :timeout (1.0) Connection acquisition timeout.
    # @option options [Integer] :size Pool size.
    # @option options [Hash] :connection see {Connection#initialize}
    def initialize(options = {})
      timeout = options.fetch(:timeout, 1.0)
      size = options.fetch(:size)

      @pool = ConnectionPool.new(size: size, timeout: timeout) do
        Connection.new(options.fetch(:connection, {}))
      end
    end

    # Run commands on a connection from pool.
    # Connection is wrapped to the {Session}.
    # @yield [session] provide {Session} to a block
    # @yieldreturn response from the last executed operation
    #
    # @example
    #   pool = Oxblood::Pool.new(size: 8)
    #   pool.with do |session|
    #     session.set('hello', 'world')
    #     session.get('hello')
    #   end # => 'world'
    def with
      conn = @pool.checkout
      yield Session.new(conn)
    ensure
      @pool.checkin if conn
    end

    # Run commands on a connection from pool. Connection is wrapped to
    # the {Pipeline}. {Pipeline#sync} operation will be executed automatically
    # at the end of a block.
    # @yield [pipeline] provide {Pipeline} to a block
    # @yieldreturn [Array] responses from all executed operations
    #
    # @example
    #  pool = Oxblood::Pool.new(size: 8)
    #  pool.pipelined do |pipeline|
    #    pipeline.set('hello', 'world')
    #    pipeline.get('hello')
    #  end # => ['OK', 'world']
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
