require 'oxblood/commands/hashes'
require 'oxblood/commands/hyper_log_log'
require 'oxblood/commands/strings'
require 'oxblood/commands/connection'
require 'oxblood/commands/geo'
require 'oxblood/commands/server'
require 'oxblood/commands/keys'
require 'oxblood/commands/lists'
require 'oxblood/commands/sets'
require 'oxblood/commands/scripting'
require 'oxblood/commands/sorted_sets'
require 'oxblood/commands/transactions'

module Oxblood
  module Commands
    include Hashes
    include HyperLogLog
    include Strings
    include Connection
    include Geo
    include Server
    include Keys
    include Lists
    include Sets
    include Scripting
    include SortedSets
    include Transactions
  end
end
