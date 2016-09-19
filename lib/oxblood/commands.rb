require 'oxblood/commands/hashes'
require 'oxblood/commands/strings'
require 'oxblood/commands/connection'
require 'oxblood/commands/server'
require 'oxblood/commands/keys'
require 'oxblood/commands/lists'
require 'oxblood/commands/sets'
require 'oxblood/commands/sorted_sets'
require 'oxblood/commands/transactions'

module Oxblood
  module Commands
    include Hashes
    include Strings
    include Connection
    include Server
    include Keys
    include Lists
    include Sets
    include SortedSets
    include Transactions
  end
end
