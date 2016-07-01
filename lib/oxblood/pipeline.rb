module Oxblood
  class Pipeline < Session
    def initialize(connection)
      super
      @commands = Array.new
    end

    def run(command)
      @commands << command
    end

    def sync
      serialized_commands = @commands.map { |c| serialize(command) }
      @connection.write(serialized_commands.join)
      @connection.read_responses(@commands.size)
    end
  end
end
