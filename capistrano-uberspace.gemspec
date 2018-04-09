# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = 'capistrano-uberspace'
  gem.version       = '1.1.2'
  gem.authors       = ['Philipp Tessenow']
  gem.email         = ['philipp@tessenow.org']
  gem.description   = %q{uberspace support for your rails app for Capistrano 3.x}
  gem.summary       = %q{uberspace support for your rails app for Capistrano 3.x}
  gem.homepage      = 'https://github.com/tessi/capistrano-uberspace'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'capistrano', '~> 3.4.0'
  gem.add_dependency 'capistrano-rails'
  gem.add_dependency 'capistrano-bundler'
  gem.add_dependency 'inifile', '~> 3.0.0'

  # dependencies for passenger on Uberspace
  gem.add_dependency 'passenger', '~> 5.0'
  gem.add_dependency 'rack', '~>2.0'

  gem.add_development_dependency 'bundler', '>= 1.3'
  gem.add_development_dependency 'rake'
end
