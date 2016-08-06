require 'oxblood/commands/strings'

RSpec.describe Oxblood::Commands::Strings do
  include_context 'test session'

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
end
