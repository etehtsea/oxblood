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
end
