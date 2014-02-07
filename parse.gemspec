# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parse/version'

Gem::Specification.new do |spec|
  spec.name          = "parse"
  spec.version       = Parse::VERSION
  spec.authors       = ["Seamus Abshere"]
  spec.email         = ["seamus@abshere.net"]
  spec.summary       = %q{Detect and convert short strings into integers, floats, dates, times, booleans, arrays, and hashes - "like a human would". Based on YAML and JSON.}
  spec.description   = %q{Detect and convert short strings into integers, floats, dates, times, booleans, arrays, and hashes - "like a human would". Based on YAML and JSON.}
  spec.homepage      = "https://github.com/seamusabshere/parse"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'safe_yaml'

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'multi_json'
  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'pry'
end
