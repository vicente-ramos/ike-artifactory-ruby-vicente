lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

# Maintain your gem's version:
# require "avvo_routes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'ike_artifactory'
  # s.version     = Deletor::VERSION
  s.version     = '0.0.1pre1'
  s.authors     = ['Avvo IKE team']
  s.email       = ['vramosgarcia@avvo.com']
  s.homepage    = ''
  s.summary     = 'Ruby gem to manipulate Artifactory repositories made by the IKE team.'
  s.description = 'IKE::Artifactory provide a set of classes to manipulate Artifactory repositories. Its propose is to provide a ruby interface to interact with Artifactory repositories.'
  s.license     = 'MIT'

  s.metadata['allowed_push_host'] = 'https://artifactory.internetbrands.com/artifactory/api/gems/avvo-ruby-local'

  s.files = Dir['{app,config,lib}/**/*', 'Rakefile', 'README.md']

  s.add_dependency 'rake'
  s.add_dependency 'rest-client'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'pry-byebug'

end
