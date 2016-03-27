module RESP
  module Protocol
    SerializerError = Class.new(RuntimeError)
    ParserError = Class.new(RuntimeError)
    RError = Class.new(RuntimeError)

    SIMPLE_STRING = '+'.freeze
    private_constant :SIMPLE_STRING

    ERROR = '-'.freeze
    private_constant :ERROR

    INTEGER = ':'.freeze
    private_constant :INTEGER

    BULK_STRING = '$'.freeze
    private_constant :BULK_STRING

    ARRAY = '*'.freeze
    private_constant :ARRAY

    TERMINATOR = "\r\n".freeze
    private_constant :TERMINATOR

    POSITIVE_INFINITY = "$4\r\n+inf\r\n".freeze
    private_constant :POSITIVE_INFINITY

    NEGATIVE_INFINITY = "$4\r\n-inf\r\n".freeze
    private_constant :NEGATIVE_INFINITY

    EMPTY_ARRAY_RESPONSE = "#{ARRAY}0#{TERMINATOR}".freeze
    private_constant :EMPTY_ARRAY_RESPONSE

    NULL_ARRAY_RESPONSE = "#{ARRAY}-1#{TERMINATOR}".freeze
    private_constant :NULL_ARRAY_RESPONSE

    EMPTY_BULK_STRING_RESPONSE = "#{BULK_STRING}0#{TERMINATOR}#{TERMINATOR}".freeze
    private_constant :EMPTY_BULK_STRING_RESPONSE

    NULL_BULK_STRING_RESPONSE = "#{BULK_STRING}-1#{TERMINATOR}".freeze
    private_constant :NULL_BULK_STRING_RESPONSE

    EMPTY_STRING = ''.freeze
    private_constant :EMPTY_STRING

    EMPTY_ARRAY = [].freeze
    private_constant :EMPTY_ARRAY

    class << self
      # Serialize command to string according to Redis Protocol
      # @see http://www.redis.io/topics/protocol
      # @raise [SerializerError] if unable to serialize given command
      # @param [Array] command array consisting of redis command and arguments
      # @return [String] serialized command
      def build_command(command)
        serialized_body = serialize_command(command)

        # FIXME FLATTEN
        "#{ARRAY}#{command.flatten.size}#{TERMINATOR}#{serialized_body}"
      end

      # Parse redis response
      # @see http://redis.io/topics/protocol
      # @raise [ParserError] if unable to parse response
      # @param [#read, #gets] io IO or IO-like object to read from
      # @return [String, RError, Integer, Array]
      def parse(io)
        line = io.gets(TERMINATOR)

        case line[0]
        when SIMPLE_STRING
          line[1..-3]
        when ERROR
          RError.new(line[1..-3])
        when INTEGER
          line[1..-3].to_i
        when BULK_STRING
          return if line == NULL_BULK_STRING_RESPONSE

          body_length = line[1..-1].to_i

          case body_length
          when -1 then nil
          when 0 then
            # discard CRLF
            io.read(2)
            EMPTY_STRING
          else
            # string length plus CRLF
            body = io.read(body_length + 2)
            body[0..-3]
          end
        when ARRAY
          return if line == NULL_ARRAY_RESPONSE
          return EMPTY_ARRAY if line == EMPTY_ARRAY_RESPONSE

          size = line[1..-1].to_i

          Array.new(size) { parse(io) }
        else
          raise ParserError.new('Unsupported response type')
        end
      end

      private

      def serialize_command(command)
        return NULL_BULK_STRING_RESPONSE if command.nil?

        case command
        when Float::INFINITY
          POSITIVE_INFINITY
        when -Float::INFINITY
          NEGATIVE_INFINITY
        when String, Symbol, Integer, Float
          command = command.to_s
          return EMPTY_BULK_STRING_RESPONSE if command.empty?

          "#{BULK_STRING}#{command.bytesize}#{TERMINATOR}#{command}#{TERMINATOR}"
        when Array
          command.map { |e| serialize_command(e) }.join
        else
          raise SerializerError.new("#{command.class} type is unsupported")
        end
      end
    end
  end
end
