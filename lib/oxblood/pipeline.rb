require 'oxblood/protocol'
require 'oxblood/commands'

module Oxblood
  # Redis pipeling class. Commands won't be send until {#sync} is called.
  # Error responses won't be raises and should be checked manually in the
  # responses array.
  # @see http://redis.io/topics/pipelining#redis-pipelining
  #
  # @example Basic workflow
  #   pipeline = Pipeline.new(connection)
  #   pipeline.echo('ping')
  #   pipeline.ping
  #   pipeline.echo('!')
  #   pipeline.sync # => ["ping", "PONG", "!"]
  class Pipeline
    include Commands

    attr_reader :connection

    def initialize(connection)
      @connection = connection
      @commands = Array.new
    end

    # Sends all commands at once and reads responses
    # @return [Array] of responses
    def sync
      serialized_commands = @commands.map { |c| Protocol.build_command(*c) }
      connection.socket.write(serialized_commands.join)
      Array.new(@commands.size) { connection.read_response }
    ensure
      @commands.clear
    end

    private

    def run(*command)
      @commands << command
    end
  end
end
