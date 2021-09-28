require "test_helper"

class UnitTestReady < Minitest::Test

  def test_not_ready
    artifactory = IKE::Artifactory::Client.new()
    refute artifactory.ready?
  end

  def test_ready
    artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :user => TEST_USER,
      :password => TEST_PASSWORD
    })
    assert artifactory.ready?
  end

  def test_no_password
    artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :user => TEST_USER
    })
    refute artifactory.ready?
  end

  def test_no_auth_data
    artifactory = IKE::Artifactory::Client.new(**{
      :server => TEST_SERVER,
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH
    })
    refute artifactory.ready?
  end

  def test_no_server
    artifactory = IKE::Artifactory::Client.new(**{
      :repo_key => TEST_REPO_KEY,
      :folder_path => TEST_FOLDER_PATH,
      :api_token => TEST_API_TOKEN
    })
    refute artifactory.ready?
  end

end


