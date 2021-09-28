require "minitest/autorun"
require 'ike_artifactory'
require 'fixtures/repo_data'
require 'pry-byebug'


raise "Please set TEST_USER environment variable" unless ENV.key?('TEST_USER')
raise "Please set TEST_PASSWORD environment variable" unless ENV.key?('TEST_PASSWORD')


class FakeResponse
  def initialize(code)
    @code = code
  end

  def code
    code
  end

  def to_s
    "fake response"
  end
end

class IKEArtifactoryTestBase < Minitest::Test
  def setup
    super
    @artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :user => TEST_USER,
      :password => TEST_PASSWORD
    })
  end
end
