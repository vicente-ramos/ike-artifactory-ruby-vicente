require "test_helper"

class UnitTestDockerCleaner < Minitest::Test

  def setup
    @artifactory = IKE::Artifactory::DockerCleaner.new(
      repo_url: 'https://artifactory.internetbrands.com/artifactory/avvo-docker-local/avvo/amos',
      days_old: 30,
      images_exclude_list: %w[fake1 fake2],
      user: 'user',
      password: 'password',
      most_recent_images: 10
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

class UnitTestDockerCleanerMethods < Minitest::Test

  def setup
    @docker_cleaner = IKE::Artifactory::DockerCleaner.new(
      repo_url: 'https://artifactory.internetbrands.com/artifactory/avvo-docker-local/avvo/amos',
      days_old: 30,
      images_exclude_list: %w[fake-x fake-y],
      user: 'user',
      password: 'password',
      most_recent_images: 2
    )
  end

  def test_call_get_children_with_repo_name
    mock_get_children = Minitest::Mock.new()
    mock_get_children.expect :call,
                             { 'fake' => 3 },
                             ['avvo/amos']


    @docker_cleaner.client.stub :get_children, mock_get_children do
      @docker_cleaner.cleanup!
    end
    assert_mock mock_get_children
  end

  def test_sort_children
    @docker_cleaner.client.stub :get_children, { 'fake1' => 3, 'fake2' => 1 } do
      @docker_cleaner.cleanup!
    end
    assert_equal @docker_cleaner.tags.to_a, { 'fake2' => 1, 'fake1' => 3 }.to_a
  end

  def test_check_if_tag_is_included_in_exclude_list
    mock_exclude_list = Minitest::Mock.new()
    mock_exclude_list.expect :call,
                             true,
                             ['fake']

    @docker_cleaner.client.stub :get_children, { 'fake' => 3 } do
      @docker_cleaner.images_exclude_list.stub :include?, mock_exclude_list do
        @docker_cleaner.cleanup!
      end
    end
    assert_mock mock_exclude_list
  end

  def test_if_tag_is_older_than_days_old_is_deleted
    mock_delete_object = Minitest::Mock.new()
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake5"]
    @docker_cleaner.client.stub :get_children, {
      'fake1' => 21, 'fake2' => 22, 'fake3' => 23, 'fake4' => 24,  'fake5' => 35, } do
      @docker_cleaner.client.stub :delete_object, mock_delete_object do
        @docker_cleaner.cleanup!
      end
    end
    assert_mock mock_delete_object
  end

  def test_images_are_excluded
    mock_delete_object = Minitest::Mock.new()
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake3"]
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake4"]
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake5"]
    @docker_cleaner.client.stub :get_children, {
      'fake-x' => 71, 'fake-y' => 62, 'fake3' => 90, 'fake4' => 91,  'fake5' => 92, } do
      @docker_cleaner.client.stub :delete_object, mock_delete_object do
        result = @docker_cleaner.cleanup!
        refute_includes result, 'fake-x'
        refute_includes result, 'fake-y'
      end
    end
    assert_mock mock_delete_object
  end

  def test_images_are_most_recent
    mock_delete_object = Minitest::Mock.new()
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake3"]
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake4"]
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake5"]
    @docker_cleaner.client.stub :get_children, {
      'fake-a' => 11, 'fake-b' => 12, 'fake3' => 31, 'fake4' => 32,  'fake5' => 33, } do
      @docker_cleaner.client.stub :delete_object, mock_delete_object do
        result = @docker_cleaner.cleanup!
        refute_includes result, 'fake-a'
        refute_includes result, 'fake-b'
      end
    end
    assert_mock mock_delete_object
  end

  def test_images_are_removed
    mock_delete_object = Minitest::Mock.new()
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake3"]
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake4"]
    mock_delete_object.expect :call,
                              true,
                              ["#{@docker_cleaner.repo_name}/fake5"]
    @docker_cleaner.client.stub :get_children, {
      'fake-a' => 11, 'fake-b' => 12, 'fake3' => 31, 'fake4' => 32,  'fake5' => 33, } do
      @docker_cleaner.client.stub :delete_object, mock_delete_object do
        result = @docker_cleaner.cleanup!
        assert_includes result, 'fake3'
        assert_includes result, 'fake4'
        assert_includes result, 'fake5'
      end
    end
    assert_mock mock_delete_object
  end
end
