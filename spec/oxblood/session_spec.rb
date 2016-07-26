require 'oxblood/session'
require 'oxblood/connection'

RSpec.describe Oxblood::Session do
  before(:context) do
    @connection = Oxblood::Connection.new
  end

  let(:connection) do
    @connection
  end

  subject do
    described_class.new(connection)
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
        described_class.new(connection)
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

  describe '#get' do
    specify do
      expect(subject.get(:nonexisting)).to eq(nil)
    end

    specify do
      connection.run_command(:SET, :key, 'value')
      expect(subject.get(:key)).to eq('value')
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

  describe '#mget' do
    specify do
      connection.run_command(:SET, :key1, 'v1')
      connection.run_command(:SET, :key2, 'v2')

      expect(subject.mget(:key1, :key2, :nonexisting)).to eq(['v1', 'v2', nil])
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
        described_class.new(connection)
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
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])

      members = ['one', 'two', 'three']
      expect(subject.zrangebyscore(:myzset, '-inf', '+inf')).to eq(members)
      expect(subject.zrangebyscore(:myzset, 1, 2)).to eq(['one', 'two'])
      expect(subject.zrangebyscore(:myzset, '(1', 2)).to eq(['two'])
      expect(subject.zrangebyscore(:myzset, '(1', '(2')).to eq([])
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

  describe '#zremrangebyscore' do
    specify do
      connection.run_command(:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three'])

      expect(subject.zremrangebyscore(:myzset, '-inf', '(2')).to eq(1)
      myzset = connection.run_command(:ZRANGE, :myzset, 0, -1, :WITHSCORES)
      expect(myzset).to eq(['two', '2', 'three', '3'])
    end
  end
end
