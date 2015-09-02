# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'optimize_player/version'

Gem::Specification.new do |spec|
  spec.name          = "optimizeplayer"
  spec.version       = OptimizePlayer::VERSION
  spec.authors       = ["Oleg Haidul"]
  spec.email         = ["oleghaidul@gmail.com"]

  spec.summary       = %q{Ruby wrapper for OptimizePlayer API}
  spec.description   = %q{A ruby library for OptimizePlayer's data API.}
  spec.homepage      = "http://github.com/optimizeplayer/optimizeplayer-ruby"
  spec.licenses      = ["MIT"]

  spec.files         = `git ls-files`.split("\n")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency('rack')
  spec.add_dependency('rest-client', '~> 1.4')
  spec.add_dependency('json', '~> 1.8.1')

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
