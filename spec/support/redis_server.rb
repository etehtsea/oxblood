require 'securerandom'
require 'thread'

class RedisServer
  TMPDIR = File.expand_path('../../../tmp', __FILE__).freeze
  LOCK = Mutex.new

  attr_reader :opts

  def self.check_stale_pidfiles!
    if !Dir["#{TMPDIR}/*.pid"].empty?
      raise "Stale Redis server pids in #{TMPDIR}"
    end
  end

  def self.global
    return @global if defined?(@global)
    LOCK.synchronize { @global ||= new.tap { |s| s.start } }
  end

  def initialize(opts = {})
    uid = SecureRandom.hex(6)

    default_opts = {
      port: 0,
      loglevel: :warning,
      pidfile: File.join(TMPDIR, "redis-server-#{uid}.pid"),
      unixsocket: File.join(TMPDIR, "redis-#{uid}.sock"),
      appendonly: :no,
      save: ''
    }

    @opts = default_opts.merge!(opts)
    @cmd = build_cmd
  end

  def start
    return @io if defined?(@io) && !@io.closed?

    @io = IO.popen(@cmd).tap do |io|
      begin
        io if io.read_nonblock(512) =~ /server started/i
      rescue Errno::EWOULDBLOCK, Errno::EAGAIN
        if IO.select([io], nil, nil, 2)
          retry
        else
          raise 'Improssible to start redis-server'
        end
      end
    end
  end

  def stop
    return if !defined?(@io) || @io.closed?

    !!Process.kill('TERM', @io.pid).tap { |_| @io.close }
  end

  def running?
    return false if @io.nil? || @io.closed?
    !!Process.kill(0, @io.pid)
  rescue Errno::ESRCH
    false
  end

  def pid
    defined?(@io) && @io.pid
  end

  private

  def build_cmd
    cmd = Array(ENV['REDIS_SERVER_BINARY'] || 'redis-server')

    @opts.flatten.each_slice(2) do |(k, v)|
      cmd << "--#{k}"
      cmd << v.to_s
    end

    cmd
  end
end
