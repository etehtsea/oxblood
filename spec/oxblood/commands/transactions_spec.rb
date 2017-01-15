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
end
