require 'oxblood/session'
require 'oxblood/connection'

RSpec.describe Oxblood::Session do
  let(:connection) do
    Oxblood::Connection.new
  end

  subject do
    described_class.new(connection)
  end

  it 'raise on error responses' do
    connection.run_command(:SET, :k, 'value')
    expect do
      subject.hset(:k, 'f', 'v')
    end.to raise_error(Oxblood::Protocol::RError)
  end

  context '#pipelined' do
    specify do
      responses = subject.pipelined { |p| 2.times { p.ping } }
      expect(responses).to match_array(['PONG', 'PONG'])
    end
  end

  context '#run_command' do
    specify do
      expect(subject.run_command(:CLIENT, :SETNAME, 'cust-name')).to eq('OK')
      expect(subject.run_command(:CLIENT, :GETNAME)).to eq('cust-name')
    end
  end
end
