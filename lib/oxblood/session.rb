require 'oxblood/commands'
require 'oxblood/protocol'

module Oxblood
  # Implements usual Request/Response protocol.
  # Error responses will be raised.
  #
  # @note {Session} don't maintain threadsafety! In multithreaded environment
  #   please use {Pool}
  #
  # @example
  #   conn = Oxblood::Connection.new
  #   session = Oxblood::Session.new(conn)
  #   session.ping # => 'PONG'
  class Session
    include Commands

    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    # Send queries using pipelining.
    # Sync operation will be executed automatically at the end of a block.
    #
    # @see https://redis.io/topics/pipelining
    #
    # @yield [pipeline] provide {Pipeline} to a block
    # @yieldreturn [Array] responses from all executed operations
    #
    # @example
    #  session = Oxblood::Session.new(Oxblood::Connection.new)
    #  session.pipelined do |pipeline|
    #    pipeline.set('hello', 'world')
    #    pipeline.get('hello')
    #  end # => ['OK', 'world']
    def pipelined
      pipeline = Pipeline.new(connection)
      yield pipeline
      pipeline.sync
    end

    # Send command to Redis server and read response from it.
    # Useful for executing unimplemented in adapter Redis commands.
    #
    # @example
    #   session.run_command(:CLIENT, :SETNAME, 'cust-name') => 'OK'
    #
    # @param [Array] command Array of command name with it's args
    def run_command(*command)
      connection.run_command(*command)
    end

    private

    def run(*command)
      response = @connection.run_command(*command)
      error?(response) ? (raise response) : response
    end

    def error?(response)
      Protocol::RError === response
    end
  end
end
