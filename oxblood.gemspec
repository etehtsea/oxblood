# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oxblood/version'

Gem::Specification.new do |spec|
  spec.name          = 'oxblood'
  spec.version       = Oxblood::VERSION
  spec.authors       = ['Konstantin Shabanov']
  spec.email         = ['etehtsea@gmail.com']

  spec.summary       = 'A Ruby Redis client'
  spec.description   = 'An experimental Ruby Redis client'
  spec.homepage      = 'https://github.com/etehtsea/oxblood'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.2.2'

  spec.add_dependency 'connection_pool'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', "~> 3.4"
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'yard'
end
