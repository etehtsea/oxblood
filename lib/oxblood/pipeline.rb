require 'oxblood/session'

module Oxblood
  # Redis pipeling class. Commands won't be send until {#sync} is called.
  # @see http://redis.io/topics/pipelining#redis-pipelining
  #
  # @example Basic workflow
  #   pipeline = Pipeline.new(connection)
  #   pipeline.echo('ping')
  #   pipeline.ping
  #   pipeline.echo('!')
  #   pipeline.sync # => ["ping", "PONG", "!"]
  class Pipeline < Session
    def initialize(connection)
      super
      @commands = Array.new
    end

    # Sends all commands at once and reads responses
    # @return [Array] of responses
    def sync
      serialized_commands = @commands.map { |c| serialize(*c) }
      @connection.write(serialized_commands.join)
      @connection.read_responses(@commands.size)
    end

    private

    def run(*command)
      @commands << command
    end
  end
end
