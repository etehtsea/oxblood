require 'benchmark/ips'
require 'oxblood/protocol'
require 'redis/connection/command_helper'

CommandHelper = Object.new.tap { |o| o.extend Redis::Connection::CommandHelper }

command = [:set, 'foo', ['bar', Float::INFINITY, -Float::INFINITY, 3]]

p CommandHelper.build_command(command)
p Oxblood::Protocol.build_command(command)
raise unless CommandHelper.build_command(command) == Oxblood::Protocol.build_command(command)

Benchmark.ips do |x|
  x.config(warmup: 20, benchmark: 10)
  x.report('redis-ruby') { CommandHelper.build_command(command) }
  x.report('Oxblood') { Oxblood::Protocol.build_command(command) }
end
