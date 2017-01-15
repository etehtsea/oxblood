require 'oxblood/commands/transactions'

RSpec.describe Oxblood::Commands::Transactions do
  include_context 'test session'

  describe '#multi' do
    after do
      connection.run_command(:DISCARD)
    end

    specify do
      expect(subject.multi).to eq('OK')
      expect(subject.connection.in_transaction?).to be_truthy
      expect(subject.multi).to be_a(Oxblood::Protocol::RError)
    end

    it 'fails with syntax error' do
      subject.multi
      connection.run_command(:INCR, 'a', 'b', 'c')
      response = subject.exec

      expect(response).to be_a(Oxblood::Protocol::RError)
      expect(response.message).to match(/EXECABORT/)
    end
  end

  describe '#exec' do
    specify do
      expect(subject.exec).to be_a(Oxblood::Protocol::RError)
    end

    specify do
      connection.run_command(:MULTI)
      connection.run_command(:PING)
      expect(subject.exec).to eq(['PONG'])
      expect(subject.connection.in_transaction?).to be_falsey
    end
  end

  describe '#discard' do
    specify do
      expect(subject.discard).to be_a(Oxblood::Protocol::RError)
    end

    specify do
      connection.run_command(:MULTI)
      expect(subject.discard).to eq('OK')
      expect(subject.connection.in_transaction?).to be_falsey
    end
  end

  describe '#watch' do
    specify do
      connection.run_command(:INCR, :k)
      expect(subject.watch(:k)).to eq('OK')
      resp = connection.run_command(:GET, :k).to_i
      resp += 1
      connection.run_command(:MULTI)
      connection.run_command(:SET, :k, resp)
      expect(connection.run_command(:EXEC)).to match_array(%w(OK))
    end

    specify do
      expect(subject.watch(:k1, :k2)).to eq('OK')
    end

    specify do
      path = RedisServer.global.opts[:unixsocket]
      subject.watch(:k)
      connection.run_command(:MULTI)
      connection.run_command(:INCR, :k)
      Oxblood::Connection.new(path: path).run_command(:INCR, :k)

      expect(connection.run_command(:EXEC)).to be_nil
    end
  end

  describe '#unwatch' do
    specify do
      expect(subject.unwatch).to eq('OK')
    end
  end
end
