$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pushr/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pushr-core"
  s.version     = Pushr::VERSION
  s.authors     = ["Tom Pesman"]
  s.email       = ["tom@tnux.net"]
  s.homepage    = "https://github.com/tompesman/pushr-core"
  s.summary     = "Core of the pushr daemon."
  s.description = "Pushr daemon for push notification services like APNS (iOS/Apple) and GCM/C2DM (Android)."

  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.files         = `git ls-files lib`.split("\n") + ["README.md", "MIT-LICENSE"]
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'redis', '~> 3'
  s.add_dependency 'redis-namespace'
  s.add_dependency 'multi_json'
  s.add_dependency 'connection_pool', '~> 1.0'
  s.add_dependency 'activemodel'
  s.add_development_dependency "sqlite3"
end
