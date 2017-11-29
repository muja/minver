# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minver/version'

Gem::Specification.new do |spec|
  spec.name          = "minver"
  spec.version       = Minver::VERSION
  spec.authors       = ["Danyel Bayraktar"]
  spec.email         = ["cydrop@gmail.com"]
  spec.summary       = %q{Minimal HTTP server with graceful shutdown & value passing}
  spec.homepage      = "https://github.com/muja/minver"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
