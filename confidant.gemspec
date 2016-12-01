# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'confidant/version'

Gem::Specification.new do |spec|

  distfiles = %w[
    .simplecov
    LICENSE.txt
    Rakefile
    version
  ]
  spec.name          = "confidant"
  spec.version       = Confidant::VERSION
  spec.authors       = ["Matt Greensmith"]
  spec.email         = ["matt.greensmith@gmail.com"]

  spec.summary       = %q{A CLI and client library for the Confidant secret management service.}
  spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = distfiles +
                       Dir[ '{lib,spec}/**/*.rb' ] +
                       Dir[ 'bin/*' ] +
                       Dir[ '*.{md,rdoc,txt}' ]
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'gli', '~> 2.14'
  spec.add_dependency 'logging', '~> 2.1'
  spec.add_dependency 'activesupport', '~> 5.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
end
