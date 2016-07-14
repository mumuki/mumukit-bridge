# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mumukit/bridge/version'

Gem::Specification.new do |spec|
  spec.name          = 'mumukit-bridge'
  spec.version       = Mumukit::Bridge::VERSION
  spec.authors       = ['Franco Leonardo Bulgarelli']
  spec.email         = ['flbulgarelli@yahoo.com.ar']
  spec.summary       = 'Library for connecting to a Mumuki test runner'
  spec.homepage      = 'http://github.com/uqbar-project/mumukit-bridge'
  spec.license       = "MIT"

  spec.files         = Dir['lib/**/**']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 2.99'

  spec.add_dependency 'rest-client'
  spec.add_dependency 'activesupport', '~> 4'
end
