require 'oxblood/commands/hyper_log_log'

RSpec.describe Oxblood::Commands::HyperLogLog do
  include_context 'test session'

  describe '#pfadd' do
    specify do
      expect(subject.pfadd(:hll)).to eq(1)
    end

    specify do
      expect(subject.pfadd(:hll, 'a', 'b', 'c')).to eq(1)
    end
  end

  describe '#pfcount' do
    specify do
      connection.run_command(:PFADD, :hll1, 'foo', 'bar', 'zap', 'a')
      connection.run_command(:PFADD, :hll2, 'a', 'b', 'c')

      expect(subject.pfcount(:hll0)).to eq(0)
      expect(subject.pfcount(:hll1)).to eq(4)
      expect(subject.pfcount(:hll2)).to eq(3)
      expect(subject.pfcount(:hll1, :hll2)).to eq(6)
    end
  end

  describe '#pfmerge' do
    specify do
      connection.run_command(:PFADD, :hll1, 'foo', 'bar', 'zap', 'a')
      connection.run_command(:PFADD, :hll2, 'a', 'b', 'c', 'foo')

      expect(subject.pfmerge(:hll3, :hll1, :hll2)).to eq('OK')
      expect(connection.run_command(:PFCOUNT, :hll3)).to eq(6)
    end
  end
end
