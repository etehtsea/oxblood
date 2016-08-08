require 'oxblood/commands/lists'

RSpec.describe Oxblood::Commands::Lists do
  include_context 'test session'

  describe '#blpop' do
    specify do
      connection.run_command(:RPUSH, :l2, 'a', 'b', 'c')

      expect(subject.blpop(:l1, :l2, 0)).to eq(%w(l2 a))
    end

    specify do
      connection.socket.timeout = 3
      expect(subject.blpop(:l1, 1)).to be_nil
    end

    specify do
      connection.run_command(:LPUSH, :l1, 'a')
      connection.socket.timeout = 3

      subject.blpop(:l1, 10)
      expect(connection.socket.timeout).to eq(3)
    end
  end

  describe '#brpop' do
    specify do
      connection.run_command(:RPUSH, :l2, 'a', 'b', 'c')

      expect(subject.brpop(:l1, :l2, 0)).to eq(%w(l2 c))
    end

    specify do
      connection.socket.timeout = 3
      expect(subject.brpop(:l1, 1)).to be_nil
    end

    specify do
      connection.run_command(:LPUSH, :l1, 'a')
      connection.socket.timeout = 3

      subject.brpop(:l1, 10)
      expect(connection.socket.timeout).to eq(3)
    end
  end

  describe '#brpoplpush' do
    specify do
      connection.run_command(:LPUSH, :source, 'a', 'b', 'c')

      expect(subject.brpoplpush(:source, :dest, 0)).to eq('a')
    end

    specify do
      connection.socket.timeout = 3
      expect(subject.brpoplpush(:source, :dest, 1)).to be_nil
    end

    specify do
      connection.run_command(:LPUSH, :source, 'a')
      connection.socket.timeout = 3

      subject.brpoplpush(:source, :dest, 10)
      expect(connection.socket.timeout).to eq(3)
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

end
