# Oxblood

[![Gem Version](https://badge.fury.io/rb/oxblood.svg)](https://badge.fury.io/rb/oxblood)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/etehtsea/oxblood/master/frames)
[![Build Status](https://travis-ci.org/etehtsea/oxblood.svg?branch=master)](https://travis-ci.org/etehtsea/oxblood)
[![Code Climate](https://codeclimate.com/github/etehtsea/oxblood/badges/gpa.svg)](https://codeclimate.com/github/etehtsea/oxblood)

A straightforward Redis Ruby client.

## Compatibility

- Ruby 2.2.2+
- JRuby 9k+

## Usage
As a starting point please look at [Oxblood::Pool](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Pool) documentation.

## Documentation
Documentation and usage examples are available on [Rubydoc](http://rubydoc.info/github/etehtsea/oxblood/master/frames).

- [Pipelining](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Pipeline)
- [Connection pooling](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Pool)
- [Connection resiliency](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/RSocket)
- Commands groups:
  - Cluster
  - [Connection](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Connection)
  - [Geo](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Geo)
  - [Hashes](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Hashes)
  - [HyperLogLog](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/HyperLogLog)
  - [Keys](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Keys)
  - [Lists](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Lists)
  - Pub/Sub
  - [Scripting](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Scripting)
  - [Server](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Server)
  - [Sets](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Sets)
  - [Sorted Sets](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/SortedSets)
  - [Strings](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Strings)
  - [Transactions](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Transactions)

## Performance
Available benchmark results are available [here](https://github.com/etehtsea/oxblood/wiki/Performance).

## Continuous Integration
You can check CI status at [Travis CI](https://travis-ci.org/etehtsea/oxblood).

## Contributing
Bug reports and pull requests are welcome on [GitHub](https://github.com/etehtsea/oxblood).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
