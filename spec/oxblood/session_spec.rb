require 'oxblood/session'

RSpec.describe Oxblood::Session do
  let(:connection) do
    Oxblood::Connection.open
  end

  subject do
    described_class.new(connection)
  end

  before do
    connection.run_command([:FLUSHDB])
  end

  describe '#hdel' do
    it 'existing field' do
      connection.run_command([:HSET, 'myhash', 'field1', 'foo'])
      expect(subject.hdel(:myhash, 'field1')).to eq(1)
    end

    it 'nonexistent field' do
      connection.run_command([:HSET, 'myhash', 'field1', 'foo'])
      expect(subject.hdel(:myhash, 'field2')).to eq(0)
    end

    it 'nonexistent key' do
      expect(subject.hdel(:nonexistentkey, 'field')).to eq(0)
    end

    it 'multiple field' do
      connection.run_command([:HMSET, 'myhash', 'f1', 1, 'f2', 2, 'f3', 3])
      expect(subject.hdel(:myhash, ['f0', 'f1', 'f2'])).to eq(2)
    end
  end

  describe '#hexists' do
    it 'existing field' do
      connection.run_command([:HSET, 'myhash', 'field1', 'foo'])
      expect(subject.hexists(:myhash, 'field1')).to eq(true)
    end

    it 'nonexistent field' do
      connection.run_command([:HSET, 'myhash', 'field1', 'foo'])
      expect(subject.hexists(:myhash, 'field2')).to eq(false)
    end

    it 'nonexistent key' do
      expect(subject.hexists(:nonexistentkey, 'field')).to eq(false)
    end
  end

  describe '#hget' do
    specify do
      connection.run_command([:HSET, 'myhash', 'f1', 'foo'])

      expect(subject.hget('myhash', 'f1')).to eq('foo')
      expect(subject.hget('myhash', 'f2')).to be_nil
      expect(subject.hget('typohash', 'f1')).to be_nil
    end
  end

  describe '#hmget' do
    specify do
      connection.run_command([:HSET, 'myhash', 'f1', 'Hello'])
      connection.run_command([:HSET, 'myhash', 'f2', 'World'])

      result = ['Hello', 'World', nil]
      expect(subject.hmget('myhash', 'f1', 'f2', 'nofield')).to eq(result)
    end
  end

  describe '#hgetall' do
    specify do
      connection.run_command([:HSET, 'myhash', 'f1', 'Hello'])
      connection.run_command([:HSET, 'myhash', 'f2', 'World'])

      expect(subject.hgetall('myhash')).to eq({ 'f1' => 'Hello', 'f2' => 'World' })
    end
  end

  describe '#hmset' do
    specify do
      expect(subject.hmset(:myhash, 'f1', 'Hello', 'f2', 'World')).to eq('OK')
      expect(connection.run_command([:HGET, 'myhash', 'f1'])).to eq('Hello')
      expect(connection.run_command([:HGET, 'myhash', 'f2'])).to eq('World')
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

  describe '#del' do
    specify do
      connection.run_command([:SET, 'key1', 'Hello'])
      connection.run_command([:SET, 'key2', 'World'])

      expect(subject.del('key1', 'key2', 'key3')).to eq(2)
    end
  end

  describe '#keys' do
    specify do
      connection.run_command([:MSET, 'one', 1, 'two', 2, 'three', 3, 'four', 4])

      expect(subject.keys('*o*')).to match_array(['two', 'four', 'one'])
      expect(subject.keys('t??')).to eq(['two'])
      expect(subject.keys('*')).to match_array(['two', 'four', 'one', 'three'])
    end
  end

  describe '#expire' do
    specify do
      connection.run_command([:SET, 'mykey', 'Hello'])

      expect(subject.expire('mykey', 100)).to eq(1)
      expect(connection.run_command([:TTL, 'mykey'])).to eq(100)
    end
  end

  describe '#sadd' do
    specify do
      expect(subject.sadd(:myset, 'Hello', 'World')).to eq(2)
      expect(subject.sadd(:myset, 'World')).to eq(0)

      cmd = [:SMEMBERS, :myset]
      expect(connection.run_command(cmd)).to eq(['Hello', 'World'])
    end
  end

  describe '#sunion' do
    specify do
      %w(a b c).each { |c| connection.run_command([:SADD, :key1, c]) }
      %w(c d e).each { |c| connection.run_command([:SADD, :key2, c]) }

      expect(subject.sunion(:key1, :key2)).to match_array(%w(a b c d e))
    end
  end

  describe '#zadd' do
    specify do
      expect(subject.zadd(:myzset, 1, 'one')).to eq(1)
      expect(subject.zadd(:myzset, [2, 'two', 3, 'three'])).to eq(2)
      cmd = [:ZRANGE, :myzset, 0, -1, 'WITHSCORES']
      result = ['one', '1', 'two', '2', 'three', '3']
      expect(connection.run_command(cmd)).to eq(result)
    end
  end

  describe '#zrangebyscore' do
    specify do
      connection.run_command([:ZADD, :myzset, [1, 'one', 2, 'two', 3, 'three']])

      members = ['one', 'two', 'three']
      expect(subject.zrangebyscore(:myzset, '-inf', '+inf')).to eq(members)
      expect(subject.zrangebyscore(:myzset, 1, 2)).to eq(['one', 'two'])
      expect(subject.zrangebyscore(:myzset, '(1', 2)).to eq(['two'])
      expect(subject.zrangebyscore(:myzset, '(1', '(2')).to eq([])
    end
  end
end
