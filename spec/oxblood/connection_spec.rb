require 'securerandom'
require 'oxblood/connection'

RSpec.describe Oxblood::Connection do
  describe '.open' do
    context 'db option' do
      def get_db_index(connection, client_name)
        db = connection.run_command(:CLIENT, :LIST).split("\n").map do |cl|
          Hash[cl.split(' ').map { |e| e.split('=') }]
        end.find { |cl| cl['name'] == client_name }['db']
      end

      specify do
        db_index = 1
        connection = described_class.open(db: db_index)
        uuid = SecureRandom.uuid
        connection.run_command(:CLIENT, :SETNAME, uuid)

        expect(get_db_index(connection, uuid)).to eq(db_index.to_s)
      end
    end

    context 'password option' do
      it 'passwordless server' do
        error_message = 'ERR Client sent AUTH, but no password is set'

        expect do
          described_class.open(password: 'hello')
        end.to raise_error(Oxblood::Protocol::RError, error_message)
      end

      context 'password secured server' do
        before(:context) do
          @redis_server = RedisServer.new(requirepass: 'hello')
          @redis_server.start
        end

        after(:context) do
          @redis_server.stop
        end

        def connect(password)
          described_class.open(
            path: @redis_server.opts[:unixsocket],
            password: password
          )
        end

        specify do
          expect(connect('hello')).to be_a(Oxblood::Connection)
        end

        specify do
          error_message = 'ERR invalid password'

          expect do
            connect('wrong')
          end.to raise_error(Oxblood::Protocol::RError, error_message)
        end
      end
    end
  end
end
