require 'oxblood/pool'

RSpec.describe Oxblood::Pool do
  subject do
    described_class.new(size: 1)
  end

  describe '#with' do
    specify do
      expect(subject.with { |s| s.echo 'hello' }).to eq('hello')
    end
  end

  describe '#pipelined' do
    specify do
      responses = subject.pipelined { |p| 3.times { p.ping } }
      expect(responses).to match_array(['PONG', 'PONG', 'PONG'])
    end
  end
end
