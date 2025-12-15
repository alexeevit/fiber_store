Gem::Specification.new do |s|
  s.name          = 'fiber_store'
  s.version       = '0.0.3'
  s.summary       = 'Per-request fiber-based storage for Rack'
  s.description   = 'Per-request fiber-based storage for Rack'
  s.authors       = ['Viacheslav Alekseev']
  s.email         = 'alexeev.corp@gmail.com'
  s.files         = ['lib/fiber_store.rb', 'lib/fiber_store/version.rb', 'lib/fiber_store/middleware.rb', 'lib/fiber_store/railtie.rb']
  s.require_paths = ['lib']
  s.homepage      = 'https://rubygems.org/gems/fiber_store'
  s.license       = 'MIT'

  s.required_ruby_version = '>= 3.2'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack'
end
