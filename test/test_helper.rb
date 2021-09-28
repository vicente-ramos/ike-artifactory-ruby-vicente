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
