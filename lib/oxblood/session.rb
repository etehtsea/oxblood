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
    include Oxblood::Commands

    def initialize(connection)
      @connection = connection
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
