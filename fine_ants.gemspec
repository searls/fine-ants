# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fine_ants/version'

Gem::Specification.new do |spec|
  spec.name          = "fine_ants"
  spec.version       = FineAnts::VERSION
  spec.authors       = ["Justin Searls"]
  spec.email         = ["searls@gmail.com"]

  spec.summary       = %q{Opens your browser and finds your bank account status.}
  spec.description   = %q{Opens your browser and finds your bank account status.}
  spec.homepage      = "https://github.com/searls/fine_ants"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capybara", "~> 2.7"
  spec.add_dependency "selenium-webdriver", "~> 2.53"

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry"

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "puffing-billy"
  spec.add_development_dependency "poltergeist"
  spec.add_development_dependency "dotenv"
end
