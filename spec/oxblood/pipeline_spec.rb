require 'oxblood/pipeline'
require 'oxblood/connection'

RSpec.describe Oxblood::Pipeline do
  describe '#sync' do
    let(:connection) do
      Oxblood::Connection.new
    end

    subject do
      described_class.new(connection)
    end

    specify do
      3.times { subject.echo 'hello' }
      expect(subject.sync).to match_array(Array.new(3) { 'hello' })
    end

    specify do
      responds = Array.new(2) do
        subject.ping
        subject.sync
      end

      expect(responds).to eq([['PONG'], ['PONG']])
    end

    specify do
      subject.rpush(:l, 'v')
      subject.blpop(:l, 1)
      expect(subject.sync.last).to match_array(%w(l v))
    end
  end
end
