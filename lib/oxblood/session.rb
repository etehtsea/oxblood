require 'oxblood/commands/hashes'
require 'oxblood/commands/strings'
require 'oxblood/commands/connection'
require 'oxblood/commands/server'
require 'oxblood/commands/keys'
require 'oxblood/commands/lists'
require 'oxblood/commands/sets'
require 'oxblood/commands/sorted_sets'

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
    def initialize(connection)
      @connection = connection
    end

    include Commands::Hashes
    include Commands::Strings
    include Commands::Connection
    include Commands::Server
    include Commands::Keys
    include Commands::Lists
    include Commands::Sets
    include Commands::SortedSets

    protected

    def serialize(*command)
      Protocol.build_command(*command)
    end

    def run(*command)
      @connection.run_command(*command)
    end
  end
end
