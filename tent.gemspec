Gem::Specification.new do |gem|
  gem.name        = 'tent'
  gem.summary     = 'Conditional object wrapping'
  gem.description = 'Apply or forget interaction with a wrapped object'
  gem.authors     = ['Josh Pencheon']
  gem.homepage    = 'http://rubygems.org/gems/tent'
  gem.license     = 'MIT'

  gem.version     = '0.0.1'
  gem.date        = '2014-09-14'
  gem.files       = ['lib/tent.rb']

  gem.add_development_dependency 'minitest', '~> 5.4.0'
  gem.add_development_dependency 'rake'
end
