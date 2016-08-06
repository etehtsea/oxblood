require 'oxblood/commands/connection'

RSpec.describe Oxblood::Commands::Connection do
  include_context 'test session'

  describe '#auth' do
    context 'with password' do
      before(:context) do
        @redis_server = RedisServer.new(requirepass: 'hello')
        @redis_server.start
      end

      after(:context) do
        @redis_server.stop
      end

      let(:connection) do
        Oxblood::Connection.new(path: @redis_server.opts[:unixsocket])
      end

      subject do
        TestSession.new(connection)
      end

      specify do
        expect(subject.auth('hello')).to eq('OK')
      end

      specify do
        response = subject.auth('wrong')
        expect(response).to be_a(Oxblood::Protocol::RError)
        expect(response.message).to eq('ERR invalid password')
      end
    end

    context 'passwordless' do
      specify do
        response = subject.auth('hello')
        expect(response).to be_a(Oxblood::Protocol::RError)
        expect(response.message).to eq('ERR Client sent AUTH, but no password is set')
      end
    end
  end

  describe '#auth!' do
    context 'with password' do
      before(:context) do
        @redis_server = RedisServer.new(requirepass: 'hello')
        @redis_server.start
      end

      after(:context) do
        @redis_server.stop
      end

      let(:connection) do
        Oxblood::Connection.new(path: @redis_server.opts[:unixsocket])
      end

      subject do
        TestSession.new(connection)
      end

      specify do
        expect(subject.auth!('hello')).to eq('OK')
      end

      specify do
        error_message = 'ERR invalid password'

        expect do
          subject.auth!('wrong')
        end.to raise_error(Oxblood::Protocol::RError, error_message)
      end
    end

    context 'passwordless' do
      specify do
        error_message = 'ERR Client sent AUTH, but no password is set'

        expect do
          subject.auth!('hello')
        end.to raise_error(Oxblood::Protocol::RError, error_message)
      end
    end
  end

  describe '#echo' do
    specify do
      expect(subject.echo('Hello')).to eq('Hello')
    end
  end

  describe '#ping' do
    specify do
      expect(subject.ping).to eq('PONG')
    end

    specify do
      msg = 'hello world'
      expect(subject.ping(msg)).to eq('hello world')
    end
  end

  describe '#quit' do
    specify do
      conn = Oxblood::Connection.new
      session = TestSession.new(conn)

      expect(session.quit).to eq('OK')
      expect(conn.socket.connected?).to eq(false)
    end
  end

  describe '#select' do
    specify do
      expect(subject.select(0)).to eq('OK')
    end

    specify do
      response = subject.select('NONSENSE')
      expect(response).to be_a(Oxblood::Protocol::RError)
      expect(response.message).to eq('ERR invalid DB index')
    end
  end
end
