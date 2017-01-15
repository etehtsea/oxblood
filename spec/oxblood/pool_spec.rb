require 'oxblood/pool'

RSpec.describe Oxblood::Pool do
  subject do
    described_class.new(size: 1)
  end

  describe '#with' do
    specify do
      expect(subject.with { |conn| conn.echo 'hello' }).to eq('hello')
    end

    context '#pipelined' do
      specify do
        responses = subject.with do |session|
          r0 = session.pipelined { |p| 2.times { p.ping } }
          r1 = session.ping
          session.ping
          r2 = session.pipelined { |p| p.echo('0') }

          [r0, r1, r2]
        end

        expect(responses).to match_array([['PONG', 'PONG'], 'PONG', ['0']])
      end
    end

    context 'multi' do
      it 'prohibit to checkin connection within transaction' do
        expect do
          2.times { subject.with { |session| session.multi } }
        end.not_to raise_error
      end
    end
  end
end
