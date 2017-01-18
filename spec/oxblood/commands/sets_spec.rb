require 'oxblood/commands/sets'

RSpec.describe Oxblood::Commands::Sets do
  include_context 'test session'

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

  describe '#sscan' do
    specify do
      subject.run_command(:SADD, :set, 'v1', 'v2', 'v3')

      response = subject.sscan(:set, 0)

      expect(response).to be_an(Array)
      expect(response.first).to eq('0')
      expect(response.last).to match_array(%w(v1 v2 v3))
    end

    context 'options' do
      before do
        values = (0...20).map { |n| n > 9 ? "z#{n}" : "t#{n}" }
        args = values.unshift(:SADD, :set)
        subject.run_command(*args)
      end

      it 'COUNT' do
        response = subject.sscan(:set, 0, count: 2)

        expect(response).to be_an(Array)
        expect(response.first).not_to eq('0')
        expect(response.last.size).to be >= 2
      end

      it 'MATCH' do
        response = subject.sscan(:set, 0, match: "*t*")

        expect(response).to be_an(Array)
        expect(response.last).to all(start_with('t'))
      end

      it 'combined' do
        response = subject.sscan(:set, 0, match: "*z*", count: 10000)

        expect(response).to be_an(Array)
        expect(response.first).to eq('0')
        expect(response.last.size).to eq(10)
      end
    end
  end
end
