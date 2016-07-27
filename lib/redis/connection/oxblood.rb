require 'redis/connection/registry'
require 'redis/errors'
require 'oxblood'

class Redis
  module Connection
    class Oxblood
      def self.connect(config)
        unless config[:path]
          config = config.dup
          config.delete(:path)
        end
        connection = ::Oxblood::Connection.new(config)

        new(connection)
      end

      def initialize(connection)
        @connection = connection
      end

      def connected?
        @connection.socket && @connection.socket.connected?
      end

      def timeout=(timeout)
        @connection.socket.timeout = timeout > 0 ? timeout : nil
      end

      def disconnect
        @connection.socket.close
      end

      def write(command)
        @connection.send_command(*command)
      end

      def read
        reply = @connection.read_response
        reply = encode(reply) if reply.is_a?(String)
        reply = CommandError.new(reply.message) if reply.is_a?(::Oxblood::Protocol::RError)
        reply
      rescue ::Oxblood::Protocol::ParserError => e
        raise Redis::ProtocolError.new(e.message)
      rescue ::Oxblood::RSocket::TimeoutError => e
        raise Redis::TimeoutError.new(e.message)
      end

      if defined?(Encoding::default_external)
        def encode(string)
          string.force_encoding(Encoding::default_external)
        end
      else
        def encode(string)
          string
        end
      end
    end
  end
end

Redis::Connection.drivers << Redis::Connection::Oxblood
