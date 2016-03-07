require 'resp/version'

module RESP
  SerializerError = Class.new(RuntimeError)
  ParserError = Class.new(RuntimeError)

  SIMPLE_STRING = '+'.freeze
  ERROR = '-'.freeze
  INTEGER = ':'.freeze
  BULK_STRING = '$'.freeze
  ARRAY = '*'.freeze

  TERMINATOR = "\r\n".freeze

  def self.command(command)
    serialize(Array(command))
  end

  def self.serialize(body)
    case body
    when String, Symbol
      RBulkString.serialize(body)
    when Integer
      RInteger.serialize(body)
    when Array
      RArray.serialize(body)
    when RError
      RError.serialize(body)
    else
      raise SerializerError.new('Unsupported type')
    end
  end

  def self.parse(response)
    case response[0]
    when SIMPLE_STRING
      RSimpleString.parse(response)
    when ERROR
      RError.parse(response)
    when INTEGER
      RInteger.parse(response)
    when BULK_STRING
      RBulkString.parse(response)
    when ARRAY
      RArray.parse(response)
    else
      raise ParserError.new('Unsupported response')
    end
  end

  class RError < RuntimeError
    def self.serialize(error)
      message = error.message
      "#{ERROR}#{message}#{TERMINATOR}"
    end

    def self.parse(response)
      message = response[1..-3]
      new(message)
    end
  end

  module RSimpleString
    def self.serialize(body)
      if body.to_s.include?("\n")
        raise SerializerError.new('No newlines are allowed in Simple Strings')
      end

      "+#{body}#{TERMINATOR}"
    end

    def self.parse(response)
      response[1..-3]
    end
  end

  module RInteger
    def self.serialize(body)
      "#{INTEGER}#{body}#{TERMINATOR}"
    end

    def self.parse(response)
      response[1..-3].to_i
    end
  end

  module RBulkString
    EMPTY = "#{BULK_STRING}0#{TERMINATOR}#{TERMINATOR}"
    NULL = "#{BULK_STRING}-1#{TERMINATOR}"

    EMPTY_STRING = ''.freeze

    def self.serialize(body)
      return NULL if body.nil?
      return EMPTY if body.empty?

      "#{BULK_STRING}#{body.size}#{TERMINATOR}#{body}#{TERMINATOR}"
    end

    def self.parse(response)
      return if response == NULL
      return EMPTY_STRING if response == EMPTY

      size = response[1..-1].to_i
      response[-size-2..-3]
    end
  end

  module RArray
    EMPTY = "#{ARRAY}0#{TERMINATOR}".freeze
    NULL = "#{ARRAY}-1#{TERMINATOR}".freeze

    EMPTY_ARRAY = [].freeze

    class << self
      def serialize(body)
        return NULL if body.nil?
        return EMPTY if body.empty?

        serialized_body = body.map { |e| RESP.serialize(e) }.join

        "#{ARRAY}#{body.size}#{TERMINATOR}#{serialized_body}"
      end

      def parse(response)
        parse!(response.dup)
      end

      private

      def parse!(response)
        return if response == NULL
        return EMPTY_ARRAY if response == EMPTY

        size = response.slice!(0, elem_length(response))[1..-3].to_i

        Array.new(size) do
          case response[0]
          when SIMPLE_STRING, ERROR, INTEGER
            RESP.parse(response.slice!(0, elem_length(response)))
          when ARRAY
            parse!(response)
          when BULK_STRING
            elem_length = elem_length(response)
            size = response[1...elem_length].to_i

            elem_length += (size + 2) if size != -1

            RESP.parse(response.slice!(0, elem_length))
          else
            raise "Array: #{response} parse error!"
          end
        end
      end

      def elem_length(response)
        i = 1

        while response[i-1..i] != TERMINATOR
          i += 1
        end

        i + 1
      end
    end
  end
end
