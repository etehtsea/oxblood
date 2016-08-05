require 'oxblood/commands'

module Oxblood
  # Implements usual Request/Response protocol
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
      @connection.run_command(*command)
    end
  end
end
