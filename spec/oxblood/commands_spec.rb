require 'oxblood/commands'
require 'oxblood/connection'

RSpec.describe Oxblood::Commands do
  class TestSession
    include Oxblood::Commands

    def initialize(conn)
      @conn = conn
    end

    private

    def run(*command)
      @conn.run_command(*command)
    end

    def connection
      @conn
    end
  end

  before(:context) do
    @connection = Oxblood::Connection.new
  end

  let(:connection) do
    @connection
  end

  subject do
    TestSession.new(connection)
  end

  after do
    connection.run_command(:FLUSHDB)
  end

  describe '#hdel' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hdel(:myhash, 'field1')).to eq(1)
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hdel(:myhash, 'field2')).to eq(0)
    end

    it 'nonexistent key' do
      expect(subject.hdel(:nonexistentkey, 'field')).to eq(0)
    end

    it 'multiple field' do
      connection.run_command(:HMSET, 'myhash', 'f1', 1, 'f2', 2, 'f3', 3)
      expect(subject.hdel(:myhash, ['f0', 'f1', 'f2'])).to eq(2)
    end
  end

  describe '#hexists' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hexists(:myhash, 'field1')).to eq(true)
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'field1', 'foo')
      expect(subject.hexists(:myhash, 'field2')).to eq(false)
    end

    it 'nonexistent key' do
      expect(subject.hexists(:nonexistentkey, 'field')).to eq(false)
    end
  end

  describe '#hget' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'foo')

      expect(subject.hget('myhash', 'f1')).to eq('foo')
      expect(subject.hget('myhash', 'f2')).to be_nil
      expect(subject.hget('typohash', 'f1')).to be_nil
    end
  end

  describe '#hgetall' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hgetall('myhash')).to eq({ 'f1' => 'Hello', 'f2' => 'World' })
    end
  end

  describe '#hincrby' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field', 5)

      expect(subject.hincrby('myhash', 'field', 1)).to eq(6)
      expect(subject.hincrby('myhash', 'field', -1)).to eq(5)
      expect(subject.hincrby('myhash', 'field', -10)).to eq(-5)
    end

    it 'nonexistent key' do
      expect(subject.hincrby('myhash', 'field', 5)).to eq(5)
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'otherfield', 5)

      expect(subject.hincrby('myhash', 'field', 5)).to eq(5)
    end
  end

  describe '#hincrbyfloat' do
    it 'existing field' do
      connection.run_command(:HSET, 'myhash', 'field1', 10.50)
      connection.run_command(:HSET, 'myhash', 'field2', '5.0e3')

      expect(subject.hincrbyfloat('myhash', 'field1', 0.1)).to eq('10.6')
      expect(subject.hincrbyfloat('myhash', 'field2', '2.0e2')).to eq('5200')
    end

    it 'nonexistent key' do
      expect(subject.hincrbyfloat('myhash', 'field', 5.0)).to eq('5')
    end

    it 'nonexistent field' do
      connection.run_command(:HSET, 'myhash', 'otherfield', 5)

      expect(subject.hincrbyfloat('myhash', 'field', 5.0)).to eq('5')
    end

    it 'field value is not parsable as a double precision' do
      connection.run_command(:HSET, 'myhash', 'field', 'asd')
      resp = subject.hincrbyfloat('myhash', 'field', 5.0)

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to eq('ERR hash value is not a valid float')
    end
  end

  describe '#hkeys' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hkeys('myhash')).to contain_exactly('f1', 'f2')
    end

    it 'nonexistent key' do
      expect(subject.hkeys('myhash')).to eq([])
    end
  end

  describe '#hlen' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hlen('myhash')).to eq(2)
    end

    it 'nonexistent key' do
      expect(subject.hlen('myhash')).to eq(0)
    end
  end

  describe '#hmget' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      result = ['Hello', 'World', nil]
      expect(subject.hmget('myhash', 'f1', 'f2', 'nofield')).to eq(result)
    end
  end

  describe '#hmset' do
    specify do
      expect(subject.hmset(:myhash, 'f1', 'Hello', 'f2', 'World')).to eq('OK')
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
      expect(connection.run_command(:HGET, 'myhash', 'f2')).to eq('World')
    end
  end

  describe '#hset' do
    it 'new field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hset('myhash', 'f2', 'World')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f2')).to eq('World')
    end

    it 'nonexistent key' do
      expect(subject.hset('myhash', 'f1', 'Hello')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
    end

    it 'updates existing field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hset('myhash', 'f1', 'World')).to eq(0)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('World')
    end
  end

  describe '#hsetnx' do
    it 'nonexistent key' do
      expect(subject.hsetnx('myhash', 'f1', 'Hello')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
    end

    it 'new field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hsetnx('myhash', 'f2', 'World')).to eq(1)
      expect(connection.run_command(:HGET, 'myhash', 'f2')).to eq('World')
    end

    it 'does not update existing field' do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')

      expect(subject.hsetnx('myhash', 'f1', 'World')).to eq(0)
      expect(connection.run_command(:HGET, 'myhash', 'f1')).to eq('Hello')
    end
  end

  describe '#hstrlen', if: server_newer_than('3.2.0') do
    specify do
      command = [:HMSET, 'myhash', 'f1', 'HelloWorld', 'f2', '99', 'f3', '-256']
      connection.run_command(*command)

      expect(subject.hstrlen('myhash', 'f1')).to eq(10)
      expect(subject.hstrlen('myhash', 'f2')).to eq(2)
      expect(subject.hstrlen('myhash', 'f3')).to eq(4)
    end

    it 'key does not exists' do
      expect(subject.hstrlen('myhash', 'f1')).to eq(0)
    end

    it 'field does not exists' do
      connection.run_command([:HSET, 'myhash', 'f1', 'Hello'])

      expect(subject.hstrlen('myhash', 'f2')).to eq(0)
    end
  end

  describe '#hvals' do
    specify do
      connection.run_command(:HSET, 'myhash', 'f1', 'Hello')
      connection.run_command(:HSET, 'myhash', 'f2', 'World')

      expect(subject.hvals('myhash')).to contain_exactly('Hello', 'World')
    end

    it 'key does not exists' do
      expect(subject.hvals('myhash')).to match_array([])
    end
  end

  describe '#auth' do
    context 'with password' do
      before(:context) do
        @redis_server = RedisServer.new(requirepass: 'hello')
        @redis_server.start
      end

      after(:context) do
        @redis_server.stop
      end

      let(:connection) do
        Oxblood::Connection.new(path: @redis_server.opts[:unixsocket])
      end

      subject do
        TestSession.new(connection)
      end

      specify do
        expect(subject.auth('hello')).to eq('OK')
      end

      specify do
        response = subject.auth('wrong')
        expect(response).to be_a(Oxblood::Protocol::RError)
        expect(response.message).to eq('ERR invalid password')
      end
    end

    context 'passwordless' do
      specify do
        response = subject.auth('hello')
        expect(response).to be_a(Oxblood::Protocol::RError)
        expect(response.message).to eq('ERR Client sent AUTH, but no password is set')
      end
    end
  end

  describe '#quit' do
    specify do
      conn = Oxblood::Connection.new
      session = TestSession.new(conn)

      expect(session.quit).to eq('OK')
      expect(conn.socket.connected?).to eq(false)
    end
  end

  describe '#append' do
    specify do
      expect(subject.append(:str, 'Hello')).to eq(5)
      expect(subject.append(:str, ' World')).to eq(11)
    end
  end

  describe '#bitcount' do
    specify do
      connection.run_command(:SET, :key, 'foobar')

      expect(subject.bitcount(:key)).to eq(26)
      expect(subject.bitcount(:key, 0, 0)).to eq(4)
      expect(subject.bitcount(:key, 1, 1)).to eq(6)
    end
  end

  describe '#bitop' do
    specify do
      connection.run_command(:SET, :k1, 'foobar')
      connection.run_command(:SET, :k2, 'abcdef')

      expect(subject.bitop(:AND, :dest, :k1, :k2)).to eq(6)
    end
  end

  describe '#bitpos' do
    specify do
      connection.run_command(:SET, :key, "\xff\xf0\x00")

      expect(subject.bitpos(:key, 0)).to eq(12)
    end

    specify do
      connection.run_command(:SET, :key, "\x00\xff\xf0")

      expect(subject.bitpos(:key, 1, 0)).to eq(8)
      expect(subject.bitpos(:key, 1, 2)).to eq(16)
    end

    specify do
      connection.run_command(:SET, :key, "\x00\x00\x00")

      expect(subject.bitpos(:key, 1)).to eq(-1)
    end
  end

  describe '#decr' do
    specify do
      connection.run_command(:SET, :key, 10)

      expect(subject.decr(:key)).to eq(9)
    end

    specify do
      connection.run_command(:SET, :key, '234293482390480948029348230948')

      expect(subject.decr(:key)).to be_a(Oxblood::Protocol::RError)
    end
  end

  describe '#decrby' do
    specify do
      connection.run_command(:SET, :key, 10)

      expect(subject.decrby(:key, 3)).to eq(7)
    end
  end

  describe '#get' do
    specify do
      expect(subject.get(:nonexisting)).to eq(nil)
    end

    specify do
      connection.run_command(:SET, :key, 'value')
      expect(subject.get(:key)).to eq('value')
    end
  end

  describe '#getbit' do
    specify do
      connection.run_command(:SETBIT, :key, 7, 1)

      expect(subject.getbit(:key, 0)).to eq(0)
      expect(subject.getbit(:key, 7)).to eq(1)
      expect(subject.getbit(:key, 100)).to eq(0)
    end
  end

  describe '#getrange' do
    specify do
      expect(subject.getrange(:none, 0, 100)).to eq('')
    end

    specify do
      connection.run_command(:SET, :key, 'This is a string')

      expect(subject.getrange(:key, 0, 3)).to eq('This')
      expect(subject.getrange(:key, -3, -1)).to eq('ing')
      expect(subject.getrange(:key, 0, -1)).to eq('This is a string')
      expect(subject.getrange(:key, 10, 100)).to eq('string')
    end
  end

  describe '#getset' do
    specify do
      expect(subject.getset(:none, 'value')).to be_nil
    end

    specify do
      connection.run_command(:SET, :key, 'value')

      expect(subject.getset(:key, 'newvalue')).to eq('value')
    end
  end

  describe '#incr' do
    specify do
      expect(subject.incr('nonexistingkey')).to eq(1)
    end

    specify do
      connection.run_command(:SET, 'mystr', 'value')
      resp = subject.incr('mystr')

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      connection.run_command(:SET, 'mystr', 10)
      expect(subject.incr('mystr')).to eq(11)
      expect(connection.run_command(:GET, 'mystr')).to eq('11')
    end
  end

  describe '#incrby' do
    specify do
      expect(subject.incrby('nonexistingkey', 10)).to eq(10)
    end

    specify do
      connection.run_command(:SET, 'mystr', 'value')
      resp = subject.incrby('mystr', 5)

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      connection.run_command(:SET, 'mystr', 10)
      expect(subject.incrby('mystr', 5)).to eq(15)
      expect(connection.run_command(:GET, 'mystr')).to eq('15')
    end
  end

  describe '#incrbyfloat' do
    specify do
      connection.run_command(:SET, :key, '10.5')

      expect(subject.incrbyfloat(:key, 0.1)).to eq('10.6')
      expect(subject.incrbyfloat(:key, -5)).to eq('5.6')
    end

    specify do
      connection.run_command(:SET, :key, '5.0e3')

      expect(subject.incrbyfloat(:key, '2.0e2')).to eq('5200')
    end
  end

  describe '#mget' do
    specify do
      connection.run_command(:SET, :key1, 'v1')
      connection.run_command(:SET, :key2, 'v2')

      expect(subject.mget(:key1, :key2, :nonexisting)).to eq(['v1', 'v2', nil])
    end
  end

  describe '#mset' do
    specify do
      expect(subject.mset(:k1, 'Hello', :k2, 'World')).to eq('OK')
    end
  end

  describe '#msetnx' do
    specify do
      expect(subject.msetnx(:k1, 'v', :k2, 'v')).to eq(1)
      expect(subject.msetnx(:k2, 'nv', :k3, 'nv')).to eq(0)
    end
  end

  describe '#psetex' do
    specify do
      expect(subject.psetex(:key, 100_000, 'Hello')).to eq('OK')
    end
  end

  describe '#set' do
    specify do
      expect(subject.set('mykey', 'Hello')).to eq('OK')
    end

    specify do
      connection.run_command(:HSET, 'key', 'field', 'value')
      expect(subject.set('key', 'Hello')).to eq('OK')
    end
  end

  describe '#setbit' do
    specify do
      expect(subject.setbit(:key, 7, 1)).to eq(0)
      expect(subject.setbit(:key, 7, 0)).to eq(1)
    end
  end

  describe '#setex' do
    specify do
      expect(subject.setex(:key, 10, 'Hello')).to eq('OK')
    end
  end

  describe '#setnx' do
    specify do
      expect(subject.setnx(:key, 'v')).to eq(1)
      expect(subject.setnx(:key, 'nv')).to eq(0)
    end
  end

  describe '#setrange' do
    specify do
      expect(subject.setrange(:key, 6, 'Redis')).to eq(11)
    end

    specify do
      connection.run_command(:SET, :key, 'Hello World')

      expect(subject.setrange(:key, 6, 'Redis')).to eq(11)
    end
  end

  describe '#strlen' do
    specify do
      expect(subject.strlen(:none)).to eq(0)
    end

    specify do
      connection.run_command(:SET, :key, 'Hello World')

      expect(subject.strlen(:key)).to eq(11)
    end
  end

  describe '#auth!' do
    context 'with password' do
      before(:context) do
        @redis_server = RedisServer.new(requirepass: 'hello')
        @redis_server.start
      end

      after(:context) do
        @redis_server.stop
      end

      let(:connection) do
        Oxblood::Connection.new(path: @redis_server.opts[:unixsocket])
      end

      subject do
        TestSession.new(connection)
      end

      specify do
        expect(subject.auth!('hello')).to eq('OK')
      end

      specify do
        error_message = 'ERR invalid password'

        expect do
          subject.auth!('wrong')
        end.to raise_error(Oxblood::Protocol::RError, error_message)
      end
    end

    context 'passwordless' do
      specify do
        error_message = 'ERR Client sent AUTH, but no password is set'

        expect do
          subject.auth!('hello')
        end.to raise_error(Oxblood::Protocol::RError, error_message)
      end
    end
  end

  describe '#echo' do
    specify do
      expect(subject.echo('Hello')).to eq('Hello')
    end
  end

  describe '#ping' do
    specify do
      expect(subject.ping).to eq('PONG')
    end

    specify do
      msg = 'hello world'
      expect(subject.ping(msg)).to eq('hello world')
    end
  end

  describe '#select' do
    specify do
      expect(subject.select(0)).to eq('OK')
    end

    specify do
      response = subject.select('NONSENSE')
      expect(response).to be_a(Oxblood::Protocol::RError)
      expect(response.message).to eq('ERR invalid DB index')
    end
  end

  describe '#flushdb' do
    specify do
      expect(subject.flushdb).to eq('OK')
    end
  end

  describe '#del' do
    specify do
      connection.run_command(:SET, 'key1', 'Hello')
      connection.run_command(:SET, 'key2', 'World')

      expect(subject.del('key1', 'key2', 'key3')).to eq(2)
    end
  end

  describe '#dump' do
    specify do
      expect(subject.dump('nonexistingkey')).to be_nil
    end

    specify do
      connection.run_command(:SET, 'key', 10)
      value = subject.dump('key')
      connection.run_command(:DEL, 'key')
      connection.run_command(:RESTORE, 'key', 0, value)
      expect(connection.run_command(:GET, 'key')).to eq('10')
    end
  end

  describe '#exists' do
    before do
      connection.run_command(:SET, 'key1', 'value')
      connection.run_command(:SET, 'key2', 'value')
    end

    specify do
      expect(subject.exists('nosuchkey')).to eq(0)
      expect(subject.exists('key1')).to eq(1)
    end

    it 'supports multiple keys', if: server_newer_than('3.0.3') do
      expect(subject.exists('key1', 'key1')).to eq(2)
      expect(subject.exists('key1', 'key2', 'nosuchkey')).to eq(2)
    end
  end

  describe '#expire' do
    specify do
      connection.run_command(:SET, 'mykey', 'Hello')

      expect(subject.expire('mykey', 100)).to eq(1)
      expect(connection.run_command(:TTL, 'mykey')).to eq(100)
    end
  end

  describe '#expireat' do
    specify do
      connection.run_command(:SET, 'mykey', 'Hello')

      expect(subject.expireat('mykey', 0)).to eq(1)
      expect(connection.run_command(:EXISTS, 'mykey')).to eq(0)
    end
  end

  describe '#keys' do
    specify do
      connection.run_command(:MSET, 'one', 1, 'two', 2, 'three', 3, 'four', 4)

      expect(subject.keys('*o*')).to match_array(['two', 'four', 'one'])
      expect(subject.keys('t??')).to eq(['two'])
      expect(subject.keys('*')).to match_array(['two', 'four', 'one', 'three'])
    end
  end

  describe '#move' do
    let(:origin_db) { 0 }
    let(:target_db) { 1 }

    after do
      connection.run_command(:SELECT, target_db)
      connection.run_command(:FLUSHDB)
      connection.run_command(:SELECT, origin_db)
    end

    specify do
      expect(subject.move('nosuchkey', target_db)).to eq(0)
    end

    specify do
      connection.run_command(:SELECT, target_db)
      connection.run_command(:SET, 'key', 'value')
      connection.run_command(:SELECT, origin_db)

      expect(subject.move('key', target_db)).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'value')

      expect(subject.move('key', target_db)).to eq(1)
    end
  end

  describe '#object' do
    specify do
      expect(subject.object(:refcount, 'nosuchkey')).to eq(nil)
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', 'Hello world')
      expect(subject.object(:refcount, 'mylist')).to be_a(Integer)
      expect(subject.object(:encoding, 'mylist')).to be_a(String)
      expect(subject.object(:idletime, 'mylist')).to be_a(Integer)
    end
  end

  describe '#persist' do
    specify do
      expect(subject.persist('nosuchkey')).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.persist('key')).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      connection.run_command(:EXPIRE, 'key', 100)

      expect(subject.persist('key')).to eq(1)
    end
  end

  describe '#pexpire' do
    specify do
      expect(subject.pexpire('nosuchkey', 15000)).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.pexpire('key', 15000)).to eq(1)
    end
  end

  describe '#pexpireat' do
    let(:tomorrow) do
      (Time.now + 86400).to_i * 1000
    end

    specify do
      expect(subject.pexpireat('nosuchkey', tomorrow)).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.pexpireat('key', tomorrow)).to eq(1)
    end
  end

  describe '#pttl' do
    specify do
      expect(subject.pttl('nosuchkey')).to be < 0
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.pttl('key')).to be < 0
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      connection.run_command(:EXPIRE, 'key', 10)

      expect(subject.pttl('key')).to be_between(1, 10000)
    end
  end

  describe '#randomkey' do
    specify do
      expect(subject.randomkey).to be_nil
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.randomkey).to eq('key')
    end
  end

  describe '#rename' do
    specify do
      error_msg = 'ERR no such key'
      response = subject.rename('nosuchkey', 'newkey')
      expect(response).to be_a(Oxblood::Protocol::RError)
      expect(response.message).to eq(error_msg)
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.rename('key', 'newkey')).to eq('OK')
      expect(connection.run_command(:GET, 'newkey')).to eq('value')
    end
  end

  describe '#renamenx' do
    specify do
      error_msg = 'ERR no such key'
      response = subject.renamenx('nosuchkey', 'newkey')
      expect(response).to be_a(Oxblood::Protocol::RError)
      expect(response.message).to eq(error_msg)
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.renamenx('key', 'newkey')).to eq(1)
      expect(connection.run_command(:GET, 'newkey')).to eq('value')
    end

    specify do
      connection.run_command(:SET, 'key', 'key')
      connection.run_command(:SET, 'newkey', 'newkey')

      expect(subject.renamenx('key', 'newkey')).to eq(0)
      expect(connection.run_command(:GET, 'newkey')).to eq('newkey')
    end
  end

  describe '#restore' do
    specify do
      connection.run_command(:SET, 'key', 10)
      value = connection.run_command(:DUMP, 'key')

      response = subject.restore('key', 0, value)
      expect(response).to be_a(Oxblood::Protocol::RError)
    end

    specify do
      connection.run_command(:SET, 'key', 10)
      value = connection.run_command(:DUMP, 'key')
      connection.run_command(:DEL, 'key')

      expect(subject.restore('key', 0, value)).to eq('OK')
      expect(connection.run_command(:GET, 'key')).to eq('10')
    end
  end

  describe '#ttl' do
    specify do
      expect(subject.ttl('nosuchkey')).to be < 0
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.ttl('key')).to be < 0
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      connection.run_command(:EXPIRE, 'key', 10)

      expect(subject.ttl('key')).to be_between(1, 10)
    end
  end

  describe '#type' do
    specify do
      expect(subject.type('key')).to eq('none')
    end

    specify do
      connection.run_command(:SET, 'key', 'value')
      expect(subject.type('key')).to eq('string')
    end
  end

  describe '#lindex' do
    specify do
      expect(subject.lindex('none', 0)).to be_nil
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', 'World', 'Hello')

      expect(subject.lindex('mylist', 0)).to eq('Hello')
      expect(subject.lindex('mylist', -1)).to eq('World')
      expect(subject.lindex('mylist', 3)).to be_nil
    end
  end

  describe '#linsert' do
    specify do
      expect(subject.linsert('none', :before, 'World', 'There')).to eq(0)
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', 'Hello', 'World')

      expect(subject.linsert('mylist', :AFTER, 'none', 'wut')).to eq(-1)
      expect(subject.linsert('mylist', :BEFORE, 'World', 'There')).to eq(3)
    end
  end

  describe '#llen' do
    specify do
      expect(subject.llen('nonexisting')).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'v')
      resp = subject.llen('key')

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', 'World')
      connection.run_command(:LPUSH, 'mylist', 'Hello')

      expect(subject.llen('mylist')).to eq(2)
    end
  end

  describe '#lpop' do
    specify do
      expect(subject.lpop('nonexisting')).to eq(nil)
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', 'Hello')

      expect(subject.lpop('mylist')).to eq('Hello')
    end
  end

  describe '#lpush' do
    specify do
      expect(subject.lpush('nonexisting', :a)).to eq(1)
    end

    specify do
      connection.run_command(:SET, 'key', 'v')
      resp = subject.lpush('key', :a, :b, :c)

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', :a)

      expect(subject.lpush('mylist', :b, :c, :d)).to eq(4)
      mylist = connection.run_command(:LRANGE, 'mylist', 0, -1)
      expect(mylist).to eq(['d', 'c', 'b', 'a'])
    end
  end

  describe '#lpushx' do
    specify do
      expect(subject.lpushx('nonexisting', :a)).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'v')
      resp = subject.lpushx('key', :a)

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', :a)

      expect(subject.lpushx('mylist', :b)).to eq(2)
      mylist = connection.run_command(:LRANGE, 'mylist', 0, -1)
      expect(mylist).to eq(['b', 'a'])
    end
  end

  describe '#lrange' do
    specify do
      expect(subject.lrange('nonexisting', 0, -1)).to eq([])
    end

    specify do
      connection.run_command(:RPUSH, 'list', 'one', 'two', 'three')

      expect(subject.lrange('list', 0, 0)).to eq(['one'])
      expect(subject.lrange('list', -3, 2)).to eq(['one', 'two', 'three'])
      expect(subject.lrange('list', -100, 100)).to eq(['one', 'two', 'three'])
      expect(subject.lrange('list', 5, 10)).to eq([])
    end
  end

  describe '#lrem' do
    specify do
      expect(subject.lrem('none', 0, 'a')).to eq(0)
    end
  end

  describe '#lset' do
    specify do
      connection.run_command(:RPUSH, 'list', 'three', 'two', 'one')

      expect(subject.lset('list', 0, 'four')).to eq('OK')
      expect(subject.lset('list', -2, 'five')).to eq('OK')
      expect(subject.lset('list', 6, 'six')).to be_a(Oxblood::Protocol::RError)
    end
  end

  describe '#ltrim' do
    specify do
      expect(subject.ltrim(:none, 1, -1)).to eq('OK')
    end
  end

  describe '#rpop' do
    specify do
      expect(subject.rpop(:mylist)).to eq(nil)
    end

    specify do
      connection.run_command(:RPUSH, 'list', 'a', 'b', 'c')

      expect(subject.rpop('list')).to eq('c')
      expect(connection.run_command(:LRANGE, 'list', 0, -1)).to eq(['a', 'b'])
    end
  end

  describe '#rpoplpush' do
    specify do
      expect(subject.rpoplpush(:none, :dest)).to eq(nil)
    end

    specify do
      connection.run_command(:RPUSH, 'source', 'c', 'b', 'a')

      expect(subject.rpoplpush(:source, :dest)).to eq('a')
    end
  end

  describe '#rpush' do
    specify do
      expect(subject.rpush('nonexisting', 1, 'str')).to eq(2)
    end

    specify do
      connection.run_command(:SET, 'key', 'v')
      resp = subject.rpush('key', 'Hello')

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', 'Hello')

      expect(subject.rpush('mylist', 'World')).to eq(2)
      members = connection.run_command(:LRANGE, 'mylist', 0, -1)
      expect(members).to eq(['Hello', 'World'])
    end
  end

  describe '#rpushx' do
    specify do
      expect(subject.rpushx('nonexisting', 'str')).to eq(0)
    end

    specify do
      connection.run_command(:SET, 'key', 'v')
      resp = subject.rpushx('key', 'Hello')

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      connection.run_command(:LPUSH, 'mylist', 'Hello')

      expect(subject.rpushx('mylist', 'World')).to eq(2)
      members = connection.run_command(:LRANGE, 'mylist', 0, -1)
      expect(members).to eq(['Hello', 'World'])
    end
  end

  describe '#sadd' do
    specify do
      expect(subject.sadd(:myset, 'Hello', 'World')).to eq(2)
      expect(subject.sadd(:myset, 'World')).to eq(0)

      cmd = [:SMEMBERS, :myset]
      expect(connection.run_command(*cmd)).to match_array(['Hello', 'World'])
    end
  end

  describe '#scard' do
    specify do
      expect(subject.scard(:nonexisting)).to eq(0)
    end

    specify do
      connection.run_command(:SADD, :myset, 'a', 'b')
      expect(subject.scard(:myset)).to eq(2)
    end
  end

  describe '#sdiff' do
    specify do
      expect(subject.sdiff(:none1, :none2)).to eq([])
    end

    specify do
      connection.run_command(:SADD, :s1, 'a', 'b', 'c')
      connection.run_command(:SADD, :s2, 'c', 'd', 'e')
      connection.run_command(:SADD, :s3, 'a', 'c', 'e')

      expect(subject.sdiff(:s1, :s2, :s3, :s4)).to eq(['b'])
    end
  end

  describe '#sdiffstore' do
    specify do
      connection.run_command(:SET, :dest, 'value')

      expect(subject.sdiffstore(:dest, :none1, :none2)).to eq(0)
      expect(connection.run_command(:SMEMBERS, :dest)).to eq([])
    end

    specify do
      connection.run_command(:SADD, :s1, 'a', 'b', 'c')
      connection.run_command(:SADD, :s2, 'c', 'd', 'e')
      connection.run_command(:SADD, :s3, 'a', 'c', 'e')

      expect(subject.sdiffstore(:dest, :s1, :s2, :s3)).to eq(1)
      expect(connection.run_command(:SMEMBERS, :dest)).to eq(['b'])
    end
  end

  describe '#sinter' do
    specify do
      connection.run_command(:SADD, :s1, 'a', 'b', 'c')
      connection.run_command(:SADD, :s2, 'c', 'd', 'e')
      connection.run_command(:SADD, :s3, 'a', 'c', 'e')

      expect(subject.sinter(:s1, :s2, :s3)).to eq(['c'])
    end

    specify do
      connection.run_command(:SADD, :s1, 'a', 'b', 'c')

      expect(subject.sinter(:s1, :none)).to eq([])
    end

  end

  describe '#sinterstore' do
    specify do
      connection.run_command(:SET, :dest, 'value')

      expect(subject.sinterstore(:dest, :none1, :none2)).to eq(0)
      expect(connection.run_command(:SMEMBERS, :dest)).to eq([])
    end

    specify do
      connection.run_command(:SADD, :s1, 'a', 'b', 'c')
      connection.run_command(:SADD, :s2, 'c', 'd', 'e')
      connection.run_command(:SADD, :s3, 'a', 'c', 'e')

      expect(subject.sinterstore(:dest, :s1, :s2, :s3)).to eq(1)
      expect(connection.run_command(:SMEMBERS, :dest)).to eq(['c'])
    end
  end

  describe '#sismember' do
    specify do
      expect(subject.sismember(:none, 'v')).to eq(0)
    end

    specify do
      connection.run_command(:SADD, :s1, 'a')
      expect(subject.sismember(:s1, 'no')).to eq(0)
      expect(subject.sismember(:s1, 'a')).to eq(1)
    end
  end

  describe '#smembers' do
    specify do
      expect(subject.smembers('nonexisting')).to eq([])
    end

    specify do
      connection.run_command(:SADD, 'myset', 'Hello')
      connection.run_command(:SADD, 'myset', 'World')

      expect(subject.smembers('myset')).to match_array(['Hello', 'World'])
    end
  end

  describe '#smove' do
    specify do
      connection.run_command(:SET, 'source', 'value')
      resp = subject.smove('source', 'dest', 'a')

      expect(resp).to be_a(Oxblood::Protocol::RError)
      expect(resp.message).to be
    end

    specify do
      expect(subject.smove(:none, :dest, 'a')).to eq(0)
    end

    specify do
      connection.run_command(:SADD, :source, 'v')

      expect(subject.smove(:source, :dest, 'a')).to eq(0)
    end

    specify do
      connection.run_command(:SADD, :source, 'v')
      connection.run_command(:SADD, :dest, 'v')

      expect(subject.smove(:source, :dest, 'v')).to eq(1)
      expect(connection.run_command(:SMEMBERS, :source)).to eq([])
    end

    specify do
      connection.run_command(:SADD, :source, 'a')
      connection.run_command(:SADD, :dest, 'v')

      expect(subject.smove(:source, :dest, 'a')).to eq(1)
      expect(connection.run_command(:SMEMBERS, :source)).to eq([])
      expect(connection.run_command(:SMEMBERS, :dest)).to match_array(%w(a v))
    end
  end

  describe '#spop' do
    specify do
      expect(subject.spop(:none)).to be_nil
    end

    specify do
      connection.run_command(:SADD, :set, 'a')

      expect(subject.spop('set')).to eq('a')
    end

    it 'count param', if: server_newer_than('3.2.0') do
      connection.run_command(:SADD, :set, 'a', 'b')

      expect(subject.spop('set', 2)).to match_array(%w(a b))
    end
  end

  describe '#srandmember' do
    specify do
      expect(subject.srandmember(:none)).to be_nil
      expect(subject.srandmember(:none, 2)).to eq([])
    end

    specify do
      connection.run_command(:SADD, :set, 'a')

      expect(subject.srandmember(:set)).to eq('a')
      expect(subject.srandmember(:set, 2)).to eq(['a'])
      expect(subject.srandmember(:set, -2)).to eq(['a', 'a'])
    end
  end

  describe '#srem' do
    specify do
      expect(subject.srem(:nonexisting, 'a')).to eq(0)
    end

    specify do
      connection.run_command(:SADD, :myset, 'one', 'two', 'three')

      expect(subject.srem(:myset, 'one', 'four')).to eq(1)
      myset = connection.run_command(:SMEMBERS, :myset)
      expect(myset).to match_array(['two', 'three'])
    end
  end

  describe '#sunion' do
    specify do
      %w(a b c).each { |c| connection.run_command(:SADD, :key1, c) }
      %w(c d e).each { |c| connection.run_command(:SADD, :key2, c) }

      expect(subject.sunion(:key1, :key2)).to match_array(%w(a b c d e))
    end
  end

  describe '#sunionstore' do
    specify do
      connection.run_command(:SET, :dest, 'value')

      expect(subject.sunionstore(:dest, :none1, :none2)).to eq(0)
      expect(connection.run_command(:SMEMBERS, :dest)).to eq([])
    end

    specify do
      connection.run_command(:SADD, :s1, 'a', 'b', 'c')
      connection.run_command(:SADD, :s2, 'c', 'd', 'e')
      connection.run_command(:SADD, :s3, 'a', 'c', 'e')

      expect(subject.sunionstore(:dest, :s1, :s2, :s3)).to eq(5)
      members = %w(a b c d e)
      expect(connection.run_command(:SMEMBERS, :dest)).to match_array(members)
    end
  end

  describe '#zadd' do
    specify do
      expect(subject.zadd(:myzset, 1, 'one')).to eq(1)
      expect(subject.zadd(:myzset, [2, 'two', 3, 'three'])).to eq(2)
      cmd = [:ZRANGE, :myzset, 0, -1, 'WITHSCORES']
      result = ['one', '1', 'two', '2', 'three', '3']
      expect(connection.run_command(*cmd)).to eq(result)
    end
  end

  describe '#zcard' do
    specify do
      expect(subject.zcard('nonexistingkey')).to eq(0)
    end

    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])
      expect(subject.zcard(:myzset)).to eq(3)
    end
  end

  describe '#zcount' do
    specify do
      connection.run_command(:ZADD, :zset, [1, 'one', 2, 'two', 3, 'three'])

      expect(subject.zcount(:zset, '-inf', '+inf')).to eq(3)
      expect(subject.zcount(:zset, '(1', '3')).to eq(2)
    end
  end

  describe '#zincrby' do
    specify do
      connection.run_command(:ZADD, :zset, [1, 'one', 2, 'two'])

      expect(subject.zincrby(:zset, 2, 'one')).to eq('3')
      expect(subject.zincrby(:anotherset, 5.46, 'two')).to eq('5.46')
    end
  end

  describe '#zlexcount' do
    specify do
      connection.run_command(:ZADD, :myzset, %w(0 a 0 b 0 c 0 d 0 e 0 f 0 g))

      expect(subject.zlexcount(:myzset, '-', '+')).to eq(7)
      expect(subject.zlexcount(:myzset, '[b', '[f')).to eq(5)
    end
  end

  describe '#zrange' do
    specify do
      expect(subject.zrange('nonexisting', 0, -1)).to eq([])
      expect(subject.zrange('nonexisting', 0, -1, withscores: true)).to eq([])
    end

    specify do
      connection.run_command(:ZADD, 'zset', 1, 'on', 2, 'tw', 3, 'th')
      with_scores = ['on', '1', 'tw', '2', 'th', '3']

      expect(subject.zrange('zset', 0, -1)).to match_array(['on', 'tw', 'th'])
      expect(subject.zrange('zset', 2, 3)).to eq(['th'])
      expect(subject.zrange('zset', -2, -1)).to eq(['tw', 'th'])
      expect(subject.zrange('zset', 0, -1, withscores: true)).to eq(with_scores)
    end
  end

  describe '#zrangebyscore' do
    specify do
      connection.run_command(:ZADD, :z, %w(1 one 2 two 3 three))

      expect(subject.zrangebyscore(:z, '-inf', '+inf')).to eq(%w(one two three))
      expect(subject.zrangebyscore(:z, 1, 2)).to eq(%w(one two))
      expect(subject.zrangebyscore(:z, '(1', 2)).to eq(%w(two))
      expect(subject.zrangebyscore(:z, '(1', '(2')).to eq([])
      expect(subject.zrangebyscore(:z, '(1', 2, withscores: true)).to eq(%w(two 2))
      expect(subject.zrangebyscore(:z, '-inf', '+inf', limit: [1, 1])).to eq(%w(two))
      opts = { withscores: true, limit: [1, 1] }
      expect(subject.zrangebyscore(:z, '-inf', '+inf', opts)).to eq(%w(two 2))
    end
  end

  describe '#zrank' do
    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])

      expect(subject.zrank(:myzset, 'three')).to eq(2)
      expect(subject.zrank(:myzset, 'four')).to be_nil
    end
  end

  describe '#zrem' do
    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one'])
      expect(subject.zrem(:myzset, 'zero', 'two')).to eq(0)
    end

    specify do
      error_msg = 'WRONGTYPE Operation against a key holding the wrong kind of value'
      connection.run_command(:SET, :mykey, 'value')
      response = subject.zrem(:mykey, 'zero')

      expect(response).to be_a(Oxblood::Protocol::RError)
      expect(response.message).to eq(error_msg)
    end

    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])
      expect(subject.zrem(:myzset, 'two')).to eq(1)
      set = connection.run_command(:ZRANGE, :myzset, 0, -1, :WITHSCORES)
      expect(set).to eq(['one', '1', 'three', '3'])
    end
  end

  describe '#zremrangebyrank' do
    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])

      expect(subject.zremrangebyrank(:myzset, 0, 1)).to eq(2)
    end
  end

  describe '#zremrangebyscore' do
    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])

      expect(subject.zremrangebyscore(:myzset, '-inf', '(2')).to eq(1)
      myzset = connection.run_command(:ZRANGE, :myzset, 0, -1, :WITHSCORES)
      expect(myzset).to eq(['two', '2', 'three', '3'])
    end
  end

  describe '#zrevrange' do
    specify do
      expect(subject.zrevrange('nonexisting', 0, -1)).to eq([])
      expect(subject.zrevrange('nonexisting', 0, -1, withscores: true)).to eq([])
    end

    specify do
      connection.run_command(:ZADD, 'zset', 1, 'on', 2, 'tw', 3, 'th')
      with_scores = %w(th 3 tw 2 on 1)

      expect(subject.zrevrange('zset', 0, -1)).to match_array(%w(th tw on))
      expect(subject.zrevrange('zset', 2, 3)).to eq(%w(on))
      expect(subject.zrevrange('zset', -2, -1)).to eq(%w(tw on))
      expect(subject.zrevrange('zset', 0, -1, withscores: true)).to eq(with_scores)
    end
  end

  describe '#zrevrangebyscore' do
    specify do
      connection.run_command(:ZADD, :z, [1, 'one', 2, 'two', 3, 'three'])

      members = %w(three two one)
      expect(subject.zrevrangebyscore(:z, '+inf', '-inf')).to eq(members)
      expect(subject.zrevrangebyscore(:z, 2, 1)).to eq(%w(two one))
      expect(subject.zrevrangebyscore(:z, 2, '(1')).to eq(%w(two))
      expect(subject.zrevrangebyscore(:z, '(2', '(1')).to eq([])
      expect(subject.zrevrangebyscore(:z, 2, '(1', withscores: true)).to eq(%w(two 2))
      expect(subject.zrevrangebyscore(:z, '+inf', '-inf', limit: [1, 1])).to eq(%w(two))
      opts = { withscores: true, limit: [1, 1] }
      expect(subject.zrevrangebyscore(:z, '+inf', '-inf', opts)).to eq(%w(two 2))
    end
  end

  describe '#zrevrank' do
    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])

      expect(subject.zrevrank(:myzset, 'one')).to eq(2)
      expect(subject.zrevrank(:myzset, 'four')).to be_nil
    end
  end

  describe '#zscore' do
    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one'])

      expect(subject.zscore(:myzset, 'one')).to eq('1')
    end
  end
end
