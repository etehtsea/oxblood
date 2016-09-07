require 'oxblood/protocol'
require 'oxblood/rsocket'
require 'oxblood/session'

module Oxblood
  # Class responsible for connection maintenance
  class Connection
    # @!attribute [r] socket
    #   @return [RSocket] resilient socket
    attr_reader :socket

    # Initialize connection to Redis server
    #
    # @param [Hash] opts Connection options
    #
    # @option opts [Float] :timeout (1.0) socket read/write timeout
    # @option opts [Integer] :db database number
    # @option opts [String] :password
    #
    # @option opts [String] :host ('localhost') Hostname or IP address to connect to
    # @option opts [Integer] :port (6379) Port Redis server listens on
    # @option opts [Float] :connect_timeout (1.0) socket connect timeout
    #
    # @option opts [String] :path UNIX socket path
    def initialize(opts = {})
      @socket = RSocket.new(opts)

      session = Session.new(self)
      session.auth(opts[:password]) if opts[:password]
      session.select(opts[:db]) if opts[:db]
    end

    # Send comand to Redis server
    # @example send_command('CONFIG', 'GET', '*') => 32
    # @param [Array] command Array of command name with it's args
    # @return [Integer] Number of bytes written to socket
    def send_command(*command)
      @socket.write(Protocol.build_command(*command))
    end

    # Send command to Redis server and read response from it
    # @example run_command('PING') => PONG
    # @param [Array] command Array of command name with it's args
    def run_command(*command)
      send_command(*command)
      read_response
    end

    # Read response from server
    # @raise [RSocket::TimeoutError] if timeout happen
    # @note Will raise RSocket::TimeoutError even if there is simply no response to read
    #       from server. For example, if you are trying to read response before
    #       sending command.
    # @todo Raise specific error if server has nothing to answer.
    def read_response
      Protocol.parse(@socket)
    end

    # Read several responses from server
    # (see #read_response)
    def read_responses(n)
      Array.new(n) { read_response }
    end
  end
end
