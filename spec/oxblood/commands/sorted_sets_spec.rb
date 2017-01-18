require 'oxblood/commands/sorted_sets'

RSpec.describe Oxblood::Commands::SortedSets do
  include_context 'test session'

  describe '#zadd' do
    specify do
      expect(subject.zadd(:myzset, 1, 'one')).to eq(1)
      expect(subject.zadd(:myzset, [2, 'two', 3, 'three'])).to eq(2)
      cmd = [:ZRANGE, :myzset, 0, -1, 'WITHSCORES']
      result = ['one', '1', 'two', '2', 'three', '3']
      expect(connection.run_command(*cmd)).to eq(result)
    end

    context 'options', if: server_newer_than('3.0.2') do
      it 'XX and NX at the same time' do
        response = subject.zadd(:zset, 1, 'one', 2, 'two', nx: true, xx: true)
        expect(response).to be_a(Oxblood::Protocol::RError)
      end

      it 'XX' do
        subject.zadd(:zset, 99, 'one', 999, 'two')
        response = subject.zadd(:zset, 1, 'one', 2, 'two', 3, 'three', xx: true)
        values = subject.run_command(:ZRANGE, :zset, 0, -1, :WITHSCORES)

        expect(response).to eq(0)
        expect(values).to match_array(%w(one 1 two 2))
      end

      it 'NX' do
        subject.zadd(:zset, 1, 'one', 2, 'two')
        response = subject.zadd(:zset, 9, 'one', 99, 'two', 0, 'zero', nx: true)
        values = subject.run_command(:ZRANGE, :zset, 0, -1, :WITHSCORES)

        expect(response).to eq(1)
        expect(values).to match_array(%w(zero 0 one 1 two 2))
      end

      it 'CH' do
        subject.zadd(:zset, 999, '0')
        resp_ch = subject.zadd(:zset, 10, '0', 1, '1', 2, '2', ch: true)
        resp_ch_xx = subject.zadd(:zset, 0, '0', 3, '3', ch: true, xx: true)

        expect(resp_ch).to eq(3)
        expect(resp_ch_xx).to eq(1)
      end

      context 'INCR' do
        it 'with multiple elements' do
          response = subject.zadd(:zset, 1, 'one', 2, 'two', incr: true)
          expect(response).to be_a(Oxblood::Protocol::RError)
        end

        it 'with one score-element pair' do
          subject.zadd(:zset, 2, 'twelve')
          expect(subject.zadd(:zset, 10, 'ten', incr: true)).to eq('10')
        end

        it 'combined with XX' do
          subject.zadd(:zset, 2, 'twelve')

          expect(subject.zadd(:zset, 10, 'ten', incr: true, xx: true)).to be_nil
          expect(subject.zadd(:zset, 10, 'twelve', incr: true, xx: true)).to eq('12')
        end

        it 'combined with NX' do
          subject.zadd(:zset, 12, 'twelve')

          expect(subject.zadd(:zset, 10, 'ten', incr: true, nx: true)).to eq('10')
          expect(subject.zadd(:zset, 10, 'twelve', incr: true, nx: true)).to be_nil
        end
      end
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

  describe '#zrangebylex', if: server_newer_than('2.8.9') do
    specify do
      elems = [0, 'a', 0, 'b', 0, 'c', 0, 'd', 0, 'e', 0, 'f', 0, 'g']
      subject.run_command(:ZADD, :zset, elems)

      expect(subject.zrangebylex(:zset, '-', '[c')).to eq(%w(a b c))
      expect(subject.zrangebylex(:zset, '-', '(c')).to eq(%w(a b))
      expect(subject.zrangebylex(:zset, '[aaa', '(g')).to eq(%w(b c d e f))
      expect(subject.zrangebylex(:zset, '[aaa', '(g', limit: [1, 1])).to eq(%w(c))
    end
  end

  describe '#zremrangebylex', if: server_newer_than('2.8.9') do
    specify do
      subject.run_command(:ZADD, :zset, 0, 'aaaa', 0, 'b', 0, 'c', 0, 'd', 0, 'e')
      subject.run_command(:ZADD, :zset, 0, 'foo', 0, 'zap', 0, 'zip', 0, 'ALPHA', 0, 'alpha')

      expect(subject.zremrangebylex(:zset, '[alpha', '[omega')).to eq(6)
    end
  end

  describe '#zrevrangebylex', if: server_newer_than('2.8.9') do
    specify do
      elems = [0, 'a', 0, 'b', 0, 'c', 0, 'd', 0, 'e', 0, 'f', 0, 'g']
      subject.run_command(:ZADD, :zset, elems)

      expect(subject.zrevrangebylex(:zset, '[c', '-')).to eq(%w(c b a))
      expect(subject.zrevrangebylex(:zset, '(c', '-')).to eq(%w(b a))
      expect(subject.zrevrangebylex(:zset, '(g', '[aaa')).to eq(%w(f e d c b))
      expect(subject.zrevrangebylex(:zset, '(g', '[aaa', limit: [1, 1])).to eq(%w(e))
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

  describe '#zscan' do
    specify do
      subject.run_command(:ZADD, :zset, 1, 'one', 2, 'two', 3, 'three')

      response = subject.zscan(:zset, 0)

      expect(response).to be_an(Array)
      expect(response.first).to eq('0')
      expect(response.last).to match_array(%w(one 1 two 2 three 3))
    end

    context 'options' do
      before do
        scores = (0...20)
        members = scores.map { |n| n > 9 ? "z#{n}" : "t#{n}" }
        args = scores.zip(members).flatten.unshift(:ZADD, :zset)
        subject.run_command(*args)
      end

      it 'MATCH' do
        response = subject.zscan(:zset, 0, match: "*t*")

        expect(response).to be_an(Array)
        expect(response.last.each_slice(2).map(&:first)).to all(start_with('t'))
      end
    end
  end

  describe '#zunionstore' do
    specify do
      subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
      subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')

      expect(subject.zunionstore(:out, 1, :z1)).to eq(2)
      expect(subject.zunionstore(:out, 2, :z1, :z2)).to eq(3)
    end

    context 'options' do
      it 'WEIGHTS' do
        subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
        subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')
        response = subject.zunionstore(:out, 2, :z1, :z2, weights: [2.0, 3.0])
        values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

        expect(response).to eq(3)
        expect(values).to match_array(%w(one 5 three 9 two 10))
      end

      context 'AGGREGATE' do
        it 'wrong value' do
          response = subject.zunionstore(:out, 1, :z1, aggregate: :div)
          expect(response).to be_a(Oxblood::Protocol::RError)
        end

        it ':min' do
          subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
          subject.run_command(:ZADD, :z2, 9, 'one', 99, 'two', 3, 'three')

          response = subject.zunionstore(:out, 2, :z1, :z2, aggregate: :min)
          values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

          expect(response).to eq(3)
          expect(values).to match_array(%w(one 1 two 2 three 3))
        end

        it ':max' do
          subject.run_command(:ZADD, :z1, 0, 'one', 1, 'two')
          subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')

          response = subject.zunionstore(:out, 2, :z1, :z2, aggregate: :max)
          values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

          expect(response).to eq(3)
          expect(values).to match_array(%w(one 1 two 2 three 3))
        end

        it ':sum' do
          subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
          subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')

          response = subject.zunionstore(:out, 2, :z1, :z2, aggregate: :sum)
          values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

          expect(response).to eq(3)
          expect(values).to match_array(%w(one 2 two 4 three 3))
        end
      end
    end
  end

  describe '#zinterstore' do
    specify do
      subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
      subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')

      expect(subject.zinterstore(:out, 1, :z1)).to eq(2)
      expect(subject.zinterstore(:out, 2, :z1, :z2)).to eq(2)
    end

    context 'options' do
      it 'WEIGHTS' do
        subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
        subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')
        response = subject.zinterstore(:out, 2, :z1, :z2, weights: [2.0, 3.0])
        values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

        expect(response).to eq(2)
        expect(values).to match_array(%w(one 5 two 10))
      end

      context 'AGGREGATE' do
        it 'wrong value' do
          response = subject.zinterstore(:out, 1, :z1, aggregate: :div)
          expect(response).to be_a(Oxblood::Protocol::RError)
        end

        it ':min' do
          subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
          subject.run_command(:ZADD, :z2, 9, 'one', 99, 'two', 3, 'three')

          response = subject.zinterstore(:out, 2, :z1, :z2, aggregate: :min)
          values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

          expect(response).to eq(2)
          expect(values).to match_array(%w(one 1 two 2))
        end

        it ':max' do
          subject.run_command(:ZADD, :z1, 0, 'one', 1, 'two')
          subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')

          response = subject.zinterstore(:out, 2, :z1, :z2, aggregate: :max)
          values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

          expect(response).to eq(2)
          expect(values).to match_array(%w(one 1 two 2))
        end

        it ':sum' do
          subject.run_command(:ZADD, :z1, 1, 'one', 2, 'two')
          subject.run_command(:ZADD, :z2, 1, 'one', 2, 'two', 3, 'three')

          response = subject.zinterstore(:out, 2, :z1, :z2, aggregate: :sum)
          values = subject.run_command(:ZRANGE, :out, 0, -1, :WITHSCORES)

          expect(response).to eq(2)
          expect(values).to match_array(%w(one 2 two 4))
        end
      end
    end
  end
end
