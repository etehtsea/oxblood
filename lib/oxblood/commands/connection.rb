module Oxblood
  module Commands
    module Connection
      # Authenticate to the server
      # @see http://redis.io/commands/auth
      #
      # @param [String] password
      #
      # @return [String] 'OK'
      # @return [RError] if wrong password was passed or server does not require
      #   password
      def auth(password)
        run(:AUTH, password)
      end

      # Echo the given string
      # @see http://redis.io/commands/echo
      #
      # @param [String] message
      #
      # @return [String] given string
      def echo(message)
        run(:ECHO, message)
      end

      # Like {#auth}, except that if error returned, raises it.
      #
      # @param [String] password
      #
      # @raise [Protocol::RError] if error returned
      #
      # @return [String] 'OK'
      def auth!(password)
        response = auth(password)
        error?(response) ? (raise response) : response
      end

      # Returns PONG if no argument is provided, otherwise return a copy of
      # the argument as a bulk
      # @see http://redis.io/commands/ping
      #
      # @param [String] message to return
      #
      # @return [String] message passed as argument
      def ping(message = nil)
        message ? run(:PING, message) : run(:PING)
      end

      # Change the selected database for the current connection
      # @see http://redis.io/commands/select
      #
      # @param [Integer] index database to switch
      #
      # @return [String] 'OK'
      # @return [RError] if wrong index was passed
      def select(index)
        run(:SELECT, index)
      end

      # Close the connection
      # @see http://redis.io/commands/quit
      #
      # @return [String] 'OK'
      def quit
        run(:QUIT)
      ensure
        @connection.socket.close
      end

      private

      def error?(response)
        Protocol::RError === response
      end
    end
  end
end
