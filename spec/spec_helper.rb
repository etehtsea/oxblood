Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |c|
  c.before(:suite) do
    RedisServer.check_stale_pidfiles!
  end

  c.after(:suite) do
    RedisServer.global.stop
  end

  c.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  c.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  c.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true unless meta.key?(:aggregate_failures)
  end

  c.filter_run :focus
  c.run_all_when_everything_filtered = true
  c.example_status_persistence_file_path = "spec/examples.txt"
  c.disable_monkey_patching!
  c.warnings = true

  c.extend ExampleGroupsHelpers

  c.default_formatter = 'doc' if c.files_to_run.one?
  c.profile_examples = 3
  c.order = :random
  Kernel.srand c.seed
end
