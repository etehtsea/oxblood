require 'digest/sha1'
require 'oxblood/commands/scripting'

RSpec.describe Oxblood::Commands::Scripting do
  include_context 'test session'

  describe '#eval' do
    specify do
      script = 'return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}'
      result = subject.eval(script, 2, :key1, :key2, :first, :second)

      expect(result).to eq(%w(key1 key2 first second))
    end

    specify do
      expect(subject.eval("return redis.call('set','foo','bar')", 0)).to eq('OK')
      expect(subject.eval("return redis.call('set',KEYS[1],'bar')", 1, :foo)).to eq('OK')
      expect(subject.eval("return 10", 0)).to eq(10)
      expect(subject.eval("return {1,2,{3,'Hello World!'}}", 0)).to eq([1, 2, [3, 'Hello World!']])
      expect(subject.eval("return redis.call('get','foo')", 0)).to eq('bar')
      expect(subject.eval("return {1,2,3.3333,'foo',nil,'bar'}", 0)).to eq([1, 2, 3, 'foo'])
    end

    context 'error handling' do
      before do
        subject.run_command(:DEL, :foo)
        subject.run_command(:LPUSH, :foo, 'a')
      end

      specify do
        script = "return redis.call('get','foo')"
        expect(subject.eval(script, 0)).to be_a(Oxblood::Protocol::RError)
      end

      specify do
        script = "return redis.pcall('get','foo')"
        expect(subject.eval(script, 0)).to be_a(Oxblood::Protocol::RError)
      end
    end
  end

  describe '#evalsha' do
    specify do
      script = 'return 2 + 2'
      subject.run_command(:SCRIPT, :LOAD, script)
      expect(subject.evalsha(Digest::SHA1.hexdigest(script), 0)).to eq(4)
    end

    specify do
      sha1 = 'ffffffffffffffffffffffffffffffffffffffff'
      expect(subject.evalsha(sha1, 0)).to be_a(Oxblood::Protocol::RError)
    end
  end

  describe '#script_debug', if: server_newer_than('3.2.0') do
    after do
      subject.run_command(:SCRIPT, :DEBUG, :no)
    end

    specify do
      expect(subject.script_debug(:yes)).to eq('OK')
    end

    specify do
      expect(subject.script_debug(:sync)).to eq('OK')
    end

    specify do
      expect(subject.script_debug(:no)).to eq('OK')
    end

    specify do
      expect(subject.script_debug(:wtf)).to be_a(Oxblood::Protocol::RError)
    end
  end

  describe '#script_exists' do
    specify do
      script = 'return 2 + 2'
      subject.run_command(:SCRIPT, :LOAD, script)
      sha1_digests = [
        Digest::SHA1.hexdigest(script),
        'ffffffffffffffffffffffffffffffffffffffff'
      ]
      expect(subject.script_exists(*sha1_digests)).to eq([1, 0])
    end
  end

  describe '#script_flush' do
    specify do
      expect(subject.script_flush).to eq('OK')
    end
  end

  describe '#script_kill' do
    specify do
      expect(subject.script_kill).to be_a(Oxblood::Protocol::RError)
    end

    context 'kill the running script' do
      around do |example|
        old_value = subject.run_command(:CONFIG, :GET, 'lua-time-limit')
        subject.run_command(:CONFIG, :SET, 'lua-time-limit', 1)
        example.run
        subject.run_command(:CONFIG, :SET, 'lua-time-limit', old_value)
      end

      specify do
        started = false

        t = Thread.new do
          started = true
          path = RedisServer.global.opts[:unixsocket]
          conn = Oxblood::Connection.new(path: path)
          conn.socket.timeout = nil
          conn.run_command(:EVAL, 'while true do end', 0)
        end

        while !(resp = subject.ping).is_a?(Oxblood::Protocol::RError) && resp !~ /BUSY/
          sleep 0.1
        end

        expect(subject.script_kill).to eq('OK')
        expect(t.value).to be_a(Oxblood::Protocol::RError)
      end
    end
  end

  describe '#script_load' do
    specify do
      script = 'return 2 + 2'
      expect(subject.script_load(script)).to eq(Digest::SHA1.hexdigest(script))
    end
  end
end
