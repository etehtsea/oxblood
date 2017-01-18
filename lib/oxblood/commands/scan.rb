module Oxblood
  module Commands
    # @api private
    module Scan
      # @note Mutates args argument!
      def self.merge_opts!(args, opts)
        if v = opts[:count]
          args.push(:COUNT, v)
        end

        if v = opts[:match]
          args.push(:MATCH, v)
        end
      end
    end
  end
end
