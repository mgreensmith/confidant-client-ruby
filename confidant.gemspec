# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'confidant/version'

Gem::Specification.new do |spec|
  distfiles = %w(
    LICENSE.txt
  )
  spec.name          = 'confidant'
  spec.version       = Confidant::VERSION
  spec.authors       = ['Matt Greensmith']
  spec.email         = ['matt@mattgreensmith.net']

  spec.summary       = 'A CLI and client library for the ' \
                       'Confidant secret management service.'
  spec.homepage      = 'https://github.com/mgreensmith/confidant-client-ruby'
  spec.license       = 'MIT'

  spec.files         = distfiles +
                       Dir['{lib,spec}/**/*.rb'] +
                       Dir['bin/*'] +
                       Dir['*.{md,rdoc,txt}']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'gli', '~> 2.14'
  spec.add_dependency 'logging', '~> 2.1'
  spec.add_dependency 'activesupport', '~> 5.0'
  spec.add_dependency 'aws-sdk-core', '~> 2.6'
  spec.add_dependency 'rest-client', '~> 2.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'pry', '~> 0.10'
end
