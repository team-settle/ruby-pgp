# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'pgp/version'

Gem::Specification.new do |gem|
  gem.name          = 'ruby-pgp'
  gem.version       = PGP::VERSION
  gem.authors       = ['Camilo Sanchez']
  gem.email         = ['gems@tddapps.com']
  gem.description   = %q{PGP for Ruby}
  gem.summary       = %q{This is a GnuPG2 wrapper modeled after the jruby-pgp api}
  gem.homepage      = 'https://github.com/cshtdd/ruby-pgp'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec'
end
