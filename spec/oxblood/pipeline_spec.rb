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
  end
end
