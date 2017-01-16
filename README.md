# Oxblood

[![Gem Version](https://badge.fury.io/rb/oxblood.svg)](https://badge.fury.io/rb/oxblood)
[![Yard Docs](http://img.shields.io/badge/yard-docs-blue.svg)](http://rubydoc.info/github/etehtsea/oxblood/master/frames)
[![Build Status](https://travis-ci.org/etehtsea/oxblood.svg?branch=master)](https://travis-ci.org/etehtsea/oxblood)
[![Code Climate](https://codeclimate.com/github/etehtsea/oxblood/badges/gpa.svg)](https://codeclimate.com/github/etehtsea/oxblood)

A straightforward Redis Ruby client.

## Compatibility

- Ruby 2.2.2+
- JRuby 9k+

## Status

- Commands:
  - Cluster (0/20)
  - [Connection](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Connection)
  - Geo (0/6)
  - [Hashes](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Hashes) (14/15) (See [#3])
  - HyperLogLog (0/3)
  - [Keys](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Keys) (18/22) (See [#4], [#6], [#7], [#8])
  - [Lists](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Lists)
  - Pub/Sub (0/6)
  - Scripting (0/7)
  - [Server](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Server) (2/31)
  - [Sets](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Sets) (14/15) (See [#10])
  - [Sorted Sets](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/SortedSets) (15/21) (See [#12], [#13], [#14], [#15])
  - [Strings](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Strings) (23/24) (See [#16])
  - [Transactions](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Commands/Transactions)
- [Pipeling](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Pipeline)
- [Connection pooling](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Pool)
- [Connection resiliency](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/RSocket)

## Usage
As a starting point please look at [Oxblood::Pool](http://www.rubydoc.info/github/etehtsea/oxblood/master/Oxblood/Pool) documentation.

## Documentation
Documentation and usage examples are available on [Rubydoc](http://rubydoc.info/github/etehtsea/oxblood/master/frames).

## Continuous Integration
You can check CI status at [Travis CI](https://travis-ci.org/etehtsea/oxblood).

## Contributing
Bug reports and pull requests are welcome on [GitHub](https://github.com/etehtsea/oxblood).

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[#3]: https://github.com/etehtsea/oxblood/issues/3
[#4]: https://github.com/etehtsea/oxblood/issues/4
[#6]: https://github.com/etehtsea/oxblood/issues/6
[#7]: https://github.com/etehtsea/oxblood/issues/7
[#8]: https://github.com/etehtsea/oxblood/issues/8
[#10]: https://github.com/etehtsea/oxblood/issues/10
[#12]: https://github.com/etehtsea/oxblood/issues/12
[#13]: https://github.com/etehtsea/oxblood/issues/13
[#14]: https://github.com/etehtsea/oxblood/issues/14
[#15]: https://github.com/etehtsea/oxblood/issues/15
[#16]: https://github.com/etehtsea/oxblood/issues/16
[#19]: https://github.com/etehtsea/oxblood/issues/19
