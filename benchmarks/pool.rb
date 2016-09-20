require 'concurrent'
require 'redis'
require 'oxblood'
require 'benchmark'

N = 10_000
TASKS = 1_000
POOL_SIZE = 32

def worker_pool
  Concurrent::FixedThreadPool.new(POOL_SIZE * 2)
end

RedisPool = ConnectionPool.new(size: POOL_SIZE) { Redis.new }
OxbloodPool = Oxblood::Pool.new(size: POOL_SIZE)

def benchmark(label, &blk)
  sec = Benchmark.realtime(&blk)
  puts [label, sec.round(3)].join(': ')
end

def run(&blk)
  pool = worker_pool
  TASKS.times { pool.post(&blk) }
  sleep 0.1 while pool.completed_task_count != TASKS
end

def redis
  RedisPool.with { |r| r.pipelined { N.times { r.ping } } }
end

def oxblood
  OxbloodPool.pipelined { |p| N.times { p.ping } }
end

# Warmup JVM
if RUBY_ENGINE == 'jruby'
  10.times do
    redis
    oxblood
  end
end

benchmark('redis-rb') { run { redis } }
benchmark('oxblood') { run { oxblood } }
