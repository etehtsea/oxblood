require 'oxblood/commands/hashes'
require 'oxblood/commands/strings'
require 'oxblood/commands/connection'
require 'oxblood/commands/server'
require 'oxblood/commands/keys'
require 'oxblood/commands/lists'
require 'oxblood/commands/sets'
require 'oxblood/commands/sorted_sets'

module Oxblood
  module Commands
    include Commands::Hashes
    include Commands::Strings
    include Commands::Connection
    include Commands::Server
    include Commands::Keys
    include Commands::Lists
    include Commands::Sets
    include Commands::SortedSets
  end
end
