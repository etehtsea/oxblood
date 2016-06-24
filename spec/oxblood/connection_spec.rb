require 'securerandom'
require 'oxblood/connection'

RSpec.describe Oxblood::Connection do
  describe '.open' do
    def get_db_index(connection, client_name)
      db = connection.run_command([:CLIENT, :LIST]).split("\n").map do |cl|
        Hash[cl.split(' ').map { |e| e.split('=') }]
      end.find { |cl| cl['name'] == client_name }['db']
    end

    specify do
      db_index = 1
      connection = described_class.open(db: db_index)
      uuid = SecureRandom.uuid
      connection.run_command([:CLIENT, :SETNAME, uuid])

      expect(get_db_index(connection, uuid)).to eq(db_index.to_s)
    end
  end
end
