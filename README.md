# RESP

Experimental Redis ruby driver.

## Usage

### Standalone

```ruby
require 'resp'
c = RESP::Connection.connect_tcp('localhost', 6379, 0.3, 0.3)
c.send_command(['SET', 'mykey', 'value']) # => 35
c.read_response # => "OK"
c.send_command(['GET', 'mykey']) # => 24
c.read_response # => "value"
```

### As [redis-rb](https://github.com/redis/redis-rb) driver

```ruby
[1] pry(main)> require 'redis/connection/resp'
=> true
[2] pry(main)> require 'redis'
=> true
# For implicit usage connection should be required before redis gem
[3] pry(main)> Redis.new.client.options[:driver]
=> Redis::Connection::Resp
# Explicitly
[4] pry(main)> Redis.new(driver: :resp).client.options[:driver]
=> Redis::Connection::Resp
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/etehtsea/resp.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
