module Oxblood
  module Commands
    module Geo
      # Add one or more geospatial items in the geospatial index represented
      # using a sorted set.
      # @see https://redis.io/commands/geoadd
      #
      # @param [String] key
      # @param [Array<[String, String, String]>] items
      #   Geospatial items (longitude, latitude, member)
      #
      # @return [Integer] The number of elements added to the sorted set,
      #   not including elements already existing for which the score was updated.
      def geoadd(key, *items)
        run(*items.unshift(:GEOADD, key))
      end

      # Returns members of a geospatial index as standard geohash strings.
      # @see https://redis.io/commands/geohash
      #
      # @param [String] key
      # @param [String, Array<String>] members
      #
      # @return [Array] The command returns an array where each element is
      #   the Geohash corresponding to each member name passed as argument to the command.
      def geohash(key, *members)
        run(*members.unshift(:GEOHASH, key))
      end

      # Returns longitude and latitude of members of a geospatial index.
      # @see https://redis.io/commands/geopos
      #
      # @param [String] key
      # @param [String, Array<String>] members
      #
      # @return [Array] an array where each element is a two elements array
      #   representing longitude and latitude (x,y) of each member name passed
      #   as argument to the command.
      #   Non existing elements are reported as `nil` elements of the array.
      def geopos(key, *members)
        run(*members.unshift(:GEOPOS, key))
      end

      # Returns the distance between two members of a geospatial index.
      # @see https://redis.io/commands/geodist
      #
      # @param [String] key
      # @param [String] member1 name of geospatial index member
      # @param [String] member2 name of geospatial index member
      # @param [nil, String] unit that could be one of the following and
      #   defaults to meters: m (meters), km (kilometers), mi (miles), ft (feet).
      #
      # @return [nil, String] The command returns the distance as a double
      #   (represented as a string) in the specified unit, or nil if one or
      #   both elements are missing.
      def geodist(key, member1, member2, unit = nil)
        if unit
          run(:GEODIST, key, member1, member2, unit)
        else
          run(:GEODIST, key, member1, member2)
        end
      end

      # Query a sorted set representing a geospatial index to fetch members
      # matching a given maximum distance from a point.
      # @see https://redis.io/commands/georadius
      #
      # @param [String] key
      # @param [String] longitude
      # @param [String] latitude
      # @param [Integer] radius
      # @param [Symbol] unit that could be one of the following and defaults to
      #   meters: m (meters), km (kilometers), mi (miles), ft (feet).
      # @param [Hash] opts
      #
      # @option opts [Boolean] :withcoord Also return the longitude, latitude
      #   coordinates of the matching items.
      # @option opts [Boolean] :withdist Also return the distance of
      #   the returned items from the specified center. The distance is returned
      #   in the same unit as the unit specified as the radius argument of
      #   the command.
      # @option opts [Boolean] :withhash Also return the raw geohash-encoded
      #   sorted set score of the item, in the form of a 52 bit unsigned integer.
      #   This is only useful for low level hacks or debugging and is otherwise
      #   of little interest for the general user.
      # @option opts [Symbol] :order The command default is to return unsorted
      #   items. Two different sorting methods can be invoked using the following
      #   two options:
      #     - ASC: from the nearest to the farthest, relative to the center.
      #     - DESC: from the farthest to the nearest, relative to the center.
      # @option opts [Integer] :count limit the results to the first N matching items.
      # @option opts [String] :store generates a valid geo index and stores
      #   result to key
      # @option opts [String] :storedist stores calculated distances to key.
      #
      # @return [Array] See https://redis.io/commands/georadius#return-value
      # @return [Integer] if STORE or STOREDIST option was used
      def georadius(key, longitude, latitude, radius, unit, opts = {})
        args = [:GEORADIUS, key, longitude, latitude, radius, unit]
        add_georadius_opts!(args, opts)
        run(*args)
      end

      # Query a sorted set representing a geospatial index to fetch members
      # matching a given maximum distance from a member.
      # @see https://redis.io/commands/georadiusbymember
      #
      # @param [String] key
      # @param [String] member
      # @param [Integer] radius
      # @param [Symbol] unit that could be one of the following and defaults to
      #   meters: m (meters), km (kilometers), mi (miles), ft (feet).
      # @param [Hash] opts
      #
      # @option opts [Boolean] :withcoord Also return the longitude, latitude
      #   coordinates of the matching items.
      # @option opts [Boolean] :withdist Also return the distance of
      #   the returned items from the specified center. The distance is returned
      #   in the same unit as the unit specified as the radius argument of
      #   the command.
      # @option opts [Boolean] :withhash Also return the raw geohash-encoded
      #   sorted set score of the item, in the form of a 52 bit unsigned integer.
      #   This is only useful for low level hacks or debugging and is otherwise
      #   of little interest for the general user.
      # @option opts [Symbol] :order The command default is to return unsorted
      #   items. Two different sorting methods can be invoked using the following
      #   two options:
      #     - ASC: from the nearest to the farthest, relative to the center.
      #     - DESC: from the farthest to the nearest, relative to the center.
      # @option opts [Integer] :count limit the results to the first N matching items.
      # @option opts [String] :store generates a valid geo index and stores
      #   result to key
      # @option opts [String] :storedist stores calculated distances to key.
      #
      # @return [Array] See https://redis.io/commands/georadius#return-value
      # @return [Integer] if STORE or STOREDIST option was used
      def georadiusbymember(key, member, radius, unit, opts = {})
        args = [:GEORADIUSBYMEMBER, key, member, radius, unit]
        add_georadius_opts!(args, opts)
        run(*args)
      end

      private

      # @note Mutates args argument!
      def add_georadius_opts!(args, opts)
        args << :WITHCOORD if opts[:withcoord]
        args << :WITHDIST if opts[:withdist]
        args << :WITHHASH if opts[:withhash]

        if order = opts[:order]
          args << order
        end

        if count = opts[:count]
          args.push(:COUNT, count)
        end

        if store_key = opts[:store]
          args.push(:STORE, store_key)
        end

        if storedist_key = opts[:storedist]
          args.push(:STOREDIST, storedist_key)
        end
      end
    end
  end
end
