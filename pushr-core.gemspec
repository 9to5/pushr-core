$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'pushr/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'pushr-core'
  s.version     = Pushr::VERSION
  s.authors     = ['Tom Pesman']
  s.email       = ['tom@tnux.net']
  s.homepage    = 'https://github.com/9to5/pushr-core'
  s.summary     = 'Core of the pushr daemon.'
  s.description = 'Pushr daemon for push notification services like APNS (iOS/Apple) and GCM (Android).'
  s.licenses    = ['MIT']

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.files         = `git ls-files lib`.split("\n") + ['README.md', 'MIT-LICENSE']
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 1.9.3'

  s.add_runtime_dependency 'redis', '~> 3'
  s.add_runtime_dependency 'redis-namespace'
  s.add_runtime_dependency 'multi_json'
  s.add_runtime_dependency 'connection_pool', '~> 2.0'
  s.add_runtime_dependency 'activemodel'
  s.add_development_dependency 'rspec', '3.0.0.beta2'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'mock_redis'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'coveralls'
end
