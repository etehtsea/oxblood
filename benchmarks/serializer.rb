require 'benchmark/ips'
require 'oxblood/protocol'
require 'redis/connection/command_helper'

CommandHelper = Object.new.tap { |o| o.extend Redis::Connection::CommandHelper }

command = [:set, 'foo', ['bar', Float::INFINITY, -Float::INFINITY, 3]]
command_name = :set
command_args = ['foo', ['bar', Float::INFINITY, -Float::INFINITY, 3]]
p ch_result = CommandHelper.build_command(command)
p ox_result = Oxblood::Protocol.build_command(command_name, *command_args)
raise unless ch_result == ox_result

Benchmark.ips do |x|
  x.config(warmup: 20, benchmark: 10)
  x.report('redis-ruby') { CommandHelper.build_command(command) }
  x.report('Oxblood') { Oxblood::Protocol.build_command(command_name, *command_args) }
end
