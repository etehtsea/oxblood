# Oxblood

[![Gem Version](https://badge.fury.io/rb/oxblood.svg)](https://badge.fury.io/rb/oxblood)

An experimental Redis Ruby client.

## Usage

### Standalone

```ruby
require 'oxblood'
pool = Oxblood::Pool.new(size: 8)
pool.with { |c| c.ping }
```

### As [redis-rb](https://github.com/redis/redis-rb) driver

```ruby
[1] pry(main)> require 'redis/connection/oxblood'
=> true
[2] pry(main)> require 'redis'
=> true
# For implicit usage connection should be required before redis gem
[3] pry(main)> Redis.new.client.options[:driver]
=> Redis::Connection::Oxblood
# Explicitly
[4] pry(main)> Redis.new(driver: :oxblood).client.options[:driver]
=> Redis::Connection::Oxblood
```

## Continuous Integration

[![Build Status](https://travis-ci.org/etehtsea/oxblood.svg?branch=master)](https://travis-ci.org/etehtsea/oxblood)

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/etehtsea/oxblood).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
