# -*- encoding: utf-8 -*-

require File.expand_path('../lib/botr/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "botr"
  gem.version       = BOTR::VERSION
  gem.summary       = %q{A ruby API kit for Bits on the Run.}
  gem.description   = %q{A ruby API kit that manages the authentication, serialization and sending of API calls to the Bits on the Run online video platform.}
  gem.license       = "MIT"
  gem.authors       = ["bertrandk"]
  gem.email         = "b.karerangabo@gmail.com"
  gem.homepage      = "https://rubygems.org/gems/botr"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  #gem.add_dependency 'thor', '~> 0.18.1'

  #gem.add_development_dependency 'rspec', '~> 2.4'
  #gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  #gem.add_development_dependency 'watchr', '~> 0.7'
  #gem.add_development_dependency 'yard', '~> 0.8'
end
