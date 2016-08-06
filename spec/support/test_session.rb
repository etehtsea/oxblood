require 'oxblood/commands'
require 'oxblood/connection'

class TestSession
  include Oxblood::Commands

  def initialize(conn)
    @conn = conn
  end

  private

  def run(*command)
    @conn.run_command(*command)
  end

  def connection
    @conn
  end
end

RSpec.shared_context 'test session' do

  before(:context) do
    @connection = Oxblood::Connection.new
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
