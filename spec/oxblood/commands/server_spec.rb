require 'oxblood/commands/server'

RSpec.describe Oxblood::Commands::Server do
  include_context 'test session'

  describe '#flushdb' do
    specify do
      expect(subject.flushdb).to eq('OK')
    end
  end
end
