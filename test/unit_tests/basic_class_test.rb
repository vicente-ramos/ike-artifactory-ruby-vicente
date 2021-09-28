require "test_helper"

class UnitTestIKEArtifactoryGem < Minitest::Test

  def setup
    super
    @artifactory = IKE::Artifactory::Client.new()
  end

  def test_server_arg
    artifactory = IKE::Artifactory::Client.new(**{:server => 'some-fake-server'}) # should not fail
    assert artifactory.server == 'some-fake-server'
  end

  def test_repo_key_arg
    artifactory = IKE::Artifactory::Client.new(**{:repo_key => 'some-fake-repo_key'}) # should not fail
    assert artifactory.repo_key == 'some-fake-repo_key'
  end

  def test_folder_path_arg
    artifactory = IKE::Artifactory::Client.new(**{:folder_path => 'some-fake-folder_path'}) # should not fail
    assert artifactory.folder_path == 'some-fake-folder_path'
  end

  def test_user_arg
    artifactory = IKE::Artifactory::Client.new(**{:user => 'some-fake-user'}) # should not fail
    assert artifactory.user == 'some-fake-user'
  end

  def test_password_arg
    artifactory = IKE::Artifactory::Client.new(**{:password => 'some-fake-password'}) # should not fail
    assert artifactory.password == 'some-fake-password'
  end

  def test_server_attribute
    assert @artifactory.respond_to? :server
    assert @artifactory.respond_to? :server=
  end

  def test_repo_key_attribute
    assert @artifactory.respond_to? :repo_key
    assert @artifactory.respond_to? :repo_key=
  end

  def test_folder_path_attribute
    assert @artifactory.respond_to? :folder_path
    assert @artifactory.respond_to? :folder_path=
  end

  def test_user_attribute
    assert @artifactory.respond_to? :user
    assert @artifactory.respond_to? :user=
  end

  def test_password_attribute
    assert @artifactory.respond_to? :password
    assert @artifactory.respond_to? :password=
  end

  def test_logs_end_of_work
    assert_equal "IKEArtifactoryGem end it's tasks", @artifactory.log_end_task
  end

end
