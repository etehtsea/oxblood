require 'securerandom'

class RedisServer
  TMPDIR = File.expand_path('../../../tmp', __FILE__).freeze
  PIDFILE = File.join(TMPDIR, 'redis-server.pid').freeze
  attr_reader :opts

  def initialize(opts = {})
    uid = SecureRandom.hex(6)

    check_pidfile!

    default_opts = {
      port: 0,
      loglevel: :warning,
      pidfile: PIDFILE,
      unixsocket: File.join(TMPDIR, "redis-#{uid}.sock")
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

  def check_pidfile!
    raise 'Redis server is alredy started' if File.exist?(PIDFILE)
  end

  def build_cmd
    cmd = Array(ENV['REDIS_SERVER_BINARY'] || 'redis-server')

    @opts.flatten.each_slice(2) do |(k, v)|
      cmd << "--#{k}"
      cmd << v.to_s
    end

    cmd
  end
end
