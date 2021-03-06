# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_dax/version'

Gem::Specification.new do |spec|
  spec.name          = 'appdax-scraper'
  spec.version       = AppDax::VERSION
  spec.authors       = ['Sebastián Katzer']
  spec.email         = ['katzer.sebastian@googlemail.com']

  spec.summary       = 'Gem to build scrapers'
  spec.homepage      = 'https://github.com/appdax/scraper-gem.git'
  spec.license       = 'GNU GPLv3'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f =~ /spec/ }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'nokogiri', '~> 1.6'

  spec.add_runtime_dependency 'typhoeus', '~> 1.0'
  spec.add_runtime_dependency 'json', '~> 2.0'
  spec.add_runtime_dependency 'hidemyass2', '~> 1.2'
end
