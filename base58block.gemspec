# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'base58block/version'

Gem::Specification.new do |spec|
  spec.name          = "base58block"
  spec.version       = Base58block::VERSION
  spec.authors       = ["David Waite"]
  spec.email         = ["david@alkaline-solutions.com"]
  spec.summary       = %q{Implementation of my own Base58-Block algorithm}
  spec.description   = %q{Encoding algorithm for human input of binary values}
  spec.homepage      = "https://github.com/dwaite/base58block"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake", "~> 10.0"
end
