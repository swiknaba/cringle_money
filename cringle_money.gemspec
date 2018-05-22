lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cringle_money/version'

Gem::Specification.new do |s|
  s.name          = 'cringle_money'
  s.version       = CringleMoney::VERSION
  s.authors       = ['Ludwig Reinmiedl']
  s.email         = ['ludwig.reinmiedl@gmail.com']
  s.summary       = 'Uses a rate service to lookup historical exchange rates'
  s.description   = 'Uses a rate service to lookup historical exchange rates'
  s.homepage      = ''
  s.license       = 'MIT'

  s.files         = Dir['lib/**/*.rb', 'spec/**/*']
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.add_dependency 'http'
  s.add_dependency 'money', '~> 6.11', '>= 6.11.3'
  s.add_dependency 'oj', '~> 3.6'
  s.add_dependency 'redis', '~> 4.0', '>= 4.0.1'

  s.add_development_dependency 'bundler', '~> 1.16', '>= 1.16.2'
  s.add_development_dependency 'mock_redis', '~> 0.18.0'
  s.add_development_dependency 'rake', '~> 12.3', '>= 12.3.1'
  s.add_development_dependency 'rspec', '~> 3.7'
  s.add_development_dependency 'rubocop', '~> 0.55.0'
end
