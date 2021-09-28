require "test_helper"

class UnitTestDockerCleaner < Minitest::Test

  def setup
    @artifactory = IKE::Artifactory::DockerCleaner.new(
      repo_uri: 'avvo-docker-local.artifactory.internetbrands.com',
      repo_name: 'avvo/amos',
      days_old: 30,
      images_exclude_list: %w[fake1 fake2]
    )
  end

  def test_repo_uri
    assert @artifactory.repo_uri == 'avvo-docker-local.artifactory.internetbrands.com'
  end

  def test_repo_repo_name
    assert @artifactory.repo_name == 'avvo/amos'
  end

  def test_days_old
    assert @artifactory.days_old == 30
  end

  def test_images_exclude_list
    assert @artifactory.images_exclude_list == %w[fake1 fake2]
  end

  def test_server_attribute
    assert @artifactory.respond_to? :repo_uri
    assert @artifactory.respond_to? :repo_uri=
  end

  def test_repo_key_attribute
    assert @artifactory.respond_to? :repo_name
    assert @artifactory.respond_to? :repo_name=
  end

  def test_folder_path_attribute
    assert @artifactory.respond_to? :days_old
    assert @artifactory.respond_to? :days_old=
  end

  def test_user_attribute
    assert @artifactory.respond_to? :images_exclude_list
    assert @artifactory.respond_to? :images_exclude_list=
  end


end

