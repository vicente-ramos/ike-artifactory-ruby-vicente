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
      images_exclude_list: %w[fake1 fake2],
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

  def test_most_recent_tags
    @docker_cleaner.client.stub :get_children, { 'fake1' => 3, 'fake2' => 111, 'fake3' => 17 } do
      @docker_cleaner.cleanup!
    end
    assert_equal %w[fake1 fake3], @docker_cleaner.most_recent_tags
  end

  def test_loop_over_each_tag
    expected_output = "Working with tag fake2\nWorking with tag fake1\n"
    @docker_cleaner.client.stub :get_children, { 'fake1' => 3, 'fake2' => 1 } do
      assert_output(expected_output) { @docker_cleaner.cleanup! }
    end
  end
  #
  # def test_check_if_tag_is_included_in_exclude_list
  #   skip('Broken.')
  #   mock_include = Minitest::Mock.new()
  #   mock_include.expect :call,
  #                       true,
  #                       ['fake']
  #
  #   client = @docker_cleaner.client
  #   client.stub get_objects_by_days_old, { 'fake' => 3 } do
  #     @docker_cleaner.images_exclude_list.stub include?, mock_include do
  #       @docker_cleaner.cleanup!
  #     end
  #   end
  # end
  #
  # def test_expected_output_when_excluded
  #   skip('Broken.')
  #   expected_output = 'Working with tag fake1\nTag fake1 is excluded.\nWorking with tag fake2'
  #   mock_include = Minitest::Mock.new()
  #   mock_include.expect :include?,
  #                       true,
  #                       ['fake1']
  #   mock_include.expect :include?,
  #                       false,
  #                       ['fake2']
  #
  #   client = @docker_cleaner.client
  #   client.stub get_objects_by_days_old, { 'fake1' => 3, 'fake2' => 4 } do
  #     @docker_cleaner.images_exclude_list.stub include?, mock_include do
  #       assert_output(expected_output) { @docker_cleaner.cleanup! }
  #     end
  #   end
  # end

end
