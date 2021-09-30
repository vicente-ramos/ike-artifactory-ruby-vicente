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

  def test_most_recent_tags
    @docker_cleaner.client.stub :get_children, { 'fake1' => 3, 'fake2' => 5, 'fake3' => 4 } do
      @docker_cleaner.cleanup!
    end
    assert_equal %w[fake1 fake3], @docker_cleaner.most_recent_tags
  end

  def test_loop_over_each_tag
    expected_output = "Working with tag fake2.\nTag fake2 is a recent image.\nWorking with tag fake1.\nTag fake1 is a recent image.\n"
    @docker_cleaner.client.stub :get_children, { 'fake1' => 3, 'fake2' => 1 } do
      assert_output(expected_output) { @docker_cleaner.cleanup! }
    end
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

  def test_image_is_excluded
    expected_output = "Working with tag fake.\nTag fake is excluded.\n"
    @docker_cleaner.client.stub :get_children, { 'fake' => 3 } do
      @docker_cleaner.images_exclude_list.stub :include?, true do
        assert_output(expected_output) { @docker_cleaner.cleanup! }
      end
    end
  end

  def test_if_excluded_go_with_next_tag
    expected_output = "Working with tag fake-x.\nTag fake-x is excluded.\nWorking with tag fake1.\nTag fake1 is a recent image.\n"
    @docker_cleaner.client.stub :get_children, { 'fake-x' => 3, 'fake1' => 3 } do
      assert_output(expected_output) { @docker_cleaner.cleanup! }
    end
  end

  def test_check_if_tag_is_most_recent_tag
    skip("The problem is that when stubbing most_recent_tags cleanup haven't be called and it is nil. nil do not have include.")
    mock_most_recent_tag = Minitest::Mock.new()
    mock_most_recent_tag.expect :call,
                                true,
                                ['fake']
    @docker_cleaner.most_recent_tags = []
    @docker_cleaner.client.stub :get_children, { 'fake' => 3 } do
      @docker_cleaner.most_recent_tags.stub :include?, mock_most_recent_tag do
        @docker_cleaner.cleanup!

      end
    end
    assert_mock mock_most_recent_tag
  end

  def test_most_recent_tag_are_excluded
    expected_output = "Working with tag fake.\nTag fake is a recent image.\n"
    @docker_cleaner.client.stub :get_children, { 'fake' => 3 } do
      assert_output(expected_output) { @docker_cleaner.cleanup! }
    end
  end

  def test_if_recent_image_go_with_next_tag
    # This test is not useful and shows that next sentence is not needed after checking if is a recent image
    expected_output = "Working with tag fake2.\nTag fake2 is a recent image.\n"
    expected_output += "Working with tag fake3.\nTag fake3 is a recent image.\n"
    expected_output += "Working with tag fake-x.\nTag fake-x is excluded.\n"
    @docker_cleaner.client.stub :get_children, {
      'fake-x' => 100, 'fake2' => 31, 'fake3' => 32, } do
      assert_output(expected_output) { @docker_cleaner.cleanup! }
    end

  end

  def test_if_tag_is_older_than_days_old
    expected_output = "Working with tag fake1.\nTag fake1 is a recent image.\n"
    expected_output += "Working with tag fake2.\nTag fake2 is a recent image.\n"
    expected_output += "Working with tag fake3.\nWorking with tag fake4.\n"
    expected_output += "Working with tag fake5.\nRemoving container image: fake5.\n"
    @docker_cleaner.client.stub :get_children, {
      'fake1' => 21, 'fake2' => 22, 'fake3' => 23, 'fake4' => 24,  'fake5' => 35, } do
      @docker_cleaner.client.stub :delete_object, true do
        assert_output(expected_output) { @docker_cleaner.cleanup! }
      end
    end
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
end
