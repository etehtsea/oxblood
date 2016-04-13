# RESP

Experimental Redis ruby driver.

## Usage

```ruby
require 'resp'
c = RESP::Connection.connect_tcp('localhost', 6379, 0.3, 0.3)
c.send_command(['SET', 'mykey', 'value']) # => 35
c.read_response # => "OK"
c.send_command(['GET', 'mykey']) # => 24
c.read_response # => "value"
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/etehtsea/resp.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
