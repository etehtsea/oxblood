require 'rubygems/version'
require 'oxblood/session'
require 'oxblood/connection'

module ExampleGroupsHelpers
  def server_newer_than(version)
    server_info = Oxblood::Session.new(Oxblood::Connection.new).info(:server)
    server_info_hash = Hash[server_info.split("\r\n")[1..-1].map { |e| e.split(':') }]
    server_version = Gem::Version.new(server_info_hash['redis_version'])

    server_version > Gem::Version.new(version)
  end
end
