require 'oxblood/commands/server'

RSpec.describe Oxblood::Commands::Server do
  include_context 'test session'

  describe '#flushdb' do
    specify do
      expect(subject.flushdb).to eq('OK')
    end
  end

  describe '#command_count' do
    specify do
      expect(subject.command_count).to be_an(Integer)
    end
  end

  describe '#command_getkeys', if: server_newer_than('3.2.0') do
    specify do
      expect(subject.command_getkeys(:MSET, :a, :b, :c, :d, :e, :f)).to match_array(%w(a c e))
    end

    specify do
      eval_args = [
        'EVAL',
        'not consulted',
        3,
        :key1,
        :key2,
        :key3,
        'arg1',
        'arg2',
        'arg3',
        'argN'
      ]
      expect(subject.command_getkeys(eval_args)).to match_array(%w(key1 key2 key3))
    end

    specify do
      args = %w(SORT mylist ALPHA STORE outlist)
      expect(subject.command_getkeys(*args)).to match_array(%w(mylist outlist))
    end
  end

  describe '#command_info' do
    specify do
      expected = [
        ['get', 2, a_collection_containing_exactly('fast', 'readonly'), 1, 1, 1],
        ['set', -3, a_collection_containing_exactly('write', 'denyoom'), 1, 1, 1],
        ['eval', -3, a_collection_containing_exactly('noscript', 'movablekeys'), 0, 0, 0]
      ]
      expect(subject.command_info(:get, :set, :eval)).to match_array(expected)
    end

    specify do
      expected = [
        nil,
        ['evalsha', -3, a_collection_containing_exactly('noscript', 'movablekeys'), 0, 0, 0],
        nil
      ]
      expect(subject.command_info(:foo, :evalsha, :bar)).to match_array(expected)
    end
  end

  describe '#config_get' do
    specify do
      expect(subject.config_get('*')).to be_an(Array)
    end
  end
end
