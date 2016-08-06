require 'oxblood/commands'

RSpec.describe Oxblood::Commands do
  specify do
    commands_groups = %w(
      Hashes Strings Connection Server Keys Lists Sets SortedSets
    ).map { |g| described_class.const_get(g) }

    expect(described_class.included_modules).to match_array(commands_groups)
  end
end
