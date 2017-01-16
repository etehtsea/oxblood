module Oxblood
  module Commands
    # @see https://redis.io/topics/transactions
    module Transactions
      # Mark the start of a transaction block
      # @see http://redis.io/commands/multi
      #
      # @example {#exec} will be executed automatically at the end of a block.
      #   session.multi do
      #     session.ping
      #     session.ping
      #   end
      #   # => ['PONG', 'PONG']
      #
      # @example Blockless variant.
      #   session.multi
      #   session.incr(:counter0)
      #   session.incr(:counter1)
      #   session.exec
      #
      # @return [String] 'OK'
      # @return [RError] if multi called inside transaction
      def multi
        response = run(:MULTI).tap do |resp|
          connection.transaction_mode = true if resp == 'OK'
        end

        if block_given?
          yield
          exec
        else
          response
        end
      end

      # Execute all commands issued after MULTI
      # @see http://redis.io/commands/exec
      #
      # @return [Array] each element being the reply to each of the commands
      #   in the atomic transaction
      # @return [nil] when WATCH was used and execution was aborted
      def exec
        run(:EXEC).tap { connection.transaction_mode = false }
      end

      # Discard all commands issued after MULTI
      # @see http://redis.io/commands/discard
      #
      # @return [String] 'OK'
      # @return [RError] if called without transaction started
      def discard
        run(:DISCARD).tap { connection.transaction_mode = false }
      end

      # Watch the given keys to determine execution of the MULTI/EXEC block
      # @see https://redis.io/commands/watch
      #
      # @example
      #   session.set(:cnt, 0)
      #   session.watch(:cnt)
      #   value = session.get(:cnt).to_i
      #   value += 1
      #   session.multi { session.set(:cnt, value) }
      #   # => `['OK']` or `nil` if `cnt` was modified while was watched
      # @return [String] 'OK'
      def watch(*keys)
        run(:WATCH, keys)
      end

      # Forget about all watched keys
      # @see https://redis.io/commands/unwatch
      #
      # @return [String] 'OK'
      def unwatch
        run(:UNWATCH)
      end
    end
  end
end
