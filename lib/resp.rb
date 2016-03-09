require 'resp/version'

module RESP
  SerializerError = Class.new(RuntimeError)
  ParserError = Class.new(RuntimeError)
  RError = Class.new(RuntimeError)

  SIMPLE_STRING = '+'.freeze
  ERROR = '-'.freeze
  INTEGER = ':'.freeze
  BULK_STRING = '$'.freeze
  ARRAY = '*'.freeze

  TERMINATOR = "\r\n".freeze

  EMPTY_ARRAY_RESPONSE = "#{ARRAY}0#{TERMINATOR}".freeze
  NULL_ARRAY_RESPONSE = "#{ARRAY}-1#{TERMINATOR}".freeze
  EMPTY_BULK_STRING_RESPONSE = "#{BULK_STRING}0#{TERMINATOR}#{TERMINATOR}"
  NULL_BULK_STRING_RESPONSE = "#{BULK_STRING}-1#{TERMINATOR}"

  EMPTY_STRING = ''.freeze
  EMPTY_ARRAY = [].freeze

  def self.command(command)
    serialize(Array(command))
  end

  def self.serialize(body)
    return NULL_BULK_STRING_RESPONSE if body.nil?

    case body
    when String, Symbol
      return EMPTY_BULK_STRING_RESPONSE if body.empty?

      "#{BULK_STRING}#{body.size}#{TERMINATOR}#{body}#{TERMINATOR}"
    when Integer
      "#{INTEGER}#{body}#{TERMINATOR}"
    when Array
      return EMPTY_ARRAY_RESPONSE if body.empty?

      serialized_body = body.map { |e| serialize(e) }.join

      "#{ARRAY}#{body.size}#{TERMINATOR}#{serialized_body}"
    when RError
      "#{ERROR}#{body.message}#{TERMINATOR}"
    else
      raise SerializerError.new("#{body.class} type is unsupported")
    end
  end

  def self.parse(io)
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
      return EMPTY_STRING if line == EMPTY_BULK_STRING_RESPONSE

      body_length = line[1..-1].to_i

      case body_length
      when -1 then nil
      when 0 then ''
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
end
