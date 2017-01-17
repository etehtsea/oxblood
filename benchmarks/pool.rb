require 'concurrent'
require 'redis'
require 'oxblood'
require 'benchmark'

N = 5_000
TASKS = 1_000
POOL_SIZE = Concurrent.processor_count + 1

Concurrent.use_stdlib_logger(Logger::DEBUG)

def worker_pool
  Concurrent::FixedThreadPool.new(POOL_SIZE)
end

RedisPool = ConnectionPool.new(size: POOL_SIZE) { Redis.new }
OxbloodPool = Oxblood::Pool.new(size: POOL_SIZE)

def benchmark(label, &blk)
  sec = Benchmark.realtime(&blk)
  puts [label, sec.round(3)].join(': ')
end

def run(name, &blk)
  puts "Running #{name}"

  pool = worker_pool
  TASKS.times { pool.post(&blk) }
  sleep 0.1 while pool.scheduled_task_count != TASKS
  pool.shutdown
  pool.wait_for_termination
  puts "#{pool.completed_task_count} tasks finished successfully"
end

def redis
  RedisPool.with do |r|
    r.pipelined do
      N.times { r.ping }
    end
  end
end

def oxblood
  OxbloodPool.with do |s|
    s.pipelined do |p|
      N.times { p.ping }
    end
  end
end

# Check that everything is working
redis
oxblood

# Warmup JVM
if RUBY_ENGINE == 'jruby'
  10.times do
    redis
    oxblood
  end
end

benchmark('redis-rb') { run('redis-rb') { redis } }
benchmark('oxblood') { run('oxblood') { oxblood } }
