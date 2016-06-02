require 'resp/command'

module RESP
  class Pipeline < Session
    def initialize(connection)
      super
      @commands = Array.new
    end

    def run(command)
      @commands << command
    end

    def sync
      @connection.write(@commands.join)
      @connection.read_responses(@commands.size)
    end
  end
end
