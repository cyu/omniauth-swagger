# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth/swagger/version'

Gem::Specification.new do |spec|
  spec.name          = "omniauth-swagger"
  spec.version       = Omniauth::Swagger::VERSION
  spec.authors       = ["Calvin Yu"]
  spec.email         = ["me@sourcebender.com"]

  spec.summary       = %q{OmniAuth strategy for authenticating from Swagger specifications}
  spec.description   = %q{Uses a spec's security definition information to build the oauth2 strategy}
  spec.homepage      = "http://github.com/incominghq/omniauth-swagger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency "omniauth-oauth2", "~> 1.3.0"
  spec.add_dependency "diesel-api-dsl", ">= 0.1.5"
end
