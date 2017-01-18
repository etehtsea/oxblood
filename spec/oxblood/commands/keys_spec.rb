require 'oxblood/commands/keys'

RSpec.describe Oxblood::Commands::Keys do
  include_context 'test session'

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

  describe '#scan' do
    specify do
      subject.run_command(:MSET, :k1, 'v1', :k2, 'v2', :k3, 'v3')

      response = subject.scan(0)

      expect(response).to be_an(Array)
      expect(response.first).to eq('0')
      expect(response.last).to match_array(%w(k1 k2 k3))
    end

    context 'options' do
      before do
        values = (0...20)
        keys = values.map { |n| n > 9 ? "z#{n}" : "t#{n}" }
        args = keys.zip(values).flatten.unshift(:MSET)
        subject.run_command(*args)
      end

      it 'COUNT' do
        response = subject.scan(0, count: 2)

        expect(response).to be_an(Array)
        expect(response.first).not_to eq('0')
        expect(response.last.size).to be >= 2
      end

      it 'MATCH' do
        response = subject.scan(0, match: "*t*")

        expect(response).to be_an(Array)
        expect(response.last).to all(start_with('t'))
      end

      it 'combined' do
        response = subject.scan(0, match: "*z*", count: 10000)

        expect(response).to be_an(Array)
        expect(response.first).to eq('0')
        expect(response.last.size).to eq(10)
      end
    end
  end
end
