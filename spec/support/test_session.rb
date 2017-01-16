require 'oxblood/session'
require 'oxblood/connection'

class TestSession < Oxblood::Session
  private

  def run(*command)
    connection.run_command(*command)
  end
end

RSpec.shared_context 'test session' do
  before(:context) do
    @connection = Oxblood::Connection.new(path: RedisServer.global.opts[:unixsocket])
  end

  let(:connection) do
    @connection
  end

  subject do
    TestSession.new(connection)
  end

  after do
    connection.run_command(:FLUSHDB)
  end
end
