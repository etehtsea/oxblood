require 'redis'
require 'oxblood'
require 'benchmark'

N = 100_000

def benchmark(label, &blk)
  sec = Benchmark.realtime(&blk)
  puts [label, sec.round(3)].join(': ')
end

def redis_without
  r = Redis.new
  N.times { r.ping }
end

def redis_with
  r = Redis.new
  r.pipelined { N.times { r.ping } }
end

def oxblood_without
  r = Oxblood::Session.new(Oxblood::Connection.new)
  N.times { r.ping }
end

def oxblood_with
  pipe = Oxblood::Pipeline.new(Oxblood::Connection.new)
  N.times { pipe.ping }
  pipe.sync
end

benchmark('redis without') { redis_without }
benchmark('redis with') { redis_with }
benchmark('oxblood without') { oxblood_without }
benchmark('oxblood with') { oxblood_with }
