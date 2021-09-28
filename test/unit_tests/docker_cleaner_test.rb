require "test_helper"

class UnitTestDockerCleaner < Minitest::Test

  def setup
    @artifactory = IKE::Artifactory::DockerCleaner.new(
      repo_url: 'https://artifactory.internetbrands.com/artifactory/avvo-docker-local/avvo/amos',
      days_old: 30,
      images_exclude_list: %w[fake1 fake2]
    )
  end

  def test_repo_url
    assert @artifactory.repo_url == 'https://artifactory.internetbrands.com/artifactory/avvo-docker-local/avvo/amos'
  end

  def test_days_old
    assert @artifactory.days_old == 30
  end

  def test_images_exclude_list
    assert @artifactory.images_exclude_list == %w[fake1 fake2]
  end

  def test_repo_name
    assert @artifactory.repo_name == 'avvo/amos'
  end

  def test_repo_key
    assert @artifactory.repo_key == 'avvo-docker-local'
  end

  def test_server_attribute
    assert @artifactory.respond_to? :repo_url
    assert @artifactory.respond_to? :repo_url=
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

