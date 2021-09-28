require "test_helper"

class UnitTestClientClass < Minitest::Test

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

class UnitTestClientMethods < Minitest::Test

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


  def test_get_object_info_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryGemNotReady do
      artifactory.get_object_info 'fake-object'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_get_object_info_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url => 'https://' + @artifactory.server +
                           '/artifactory/api/storage/' + @artifactory.repo_key + '/' + 'fake-object',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_object_info 'fake-object'
    end
    assert_mock mock_request
  end

  def test_get_object_info_return_nil_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404
    mock_response.expect :to_str, '{ "test": "fake" }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.get_object_info 'fake-object'
      assert_nil result
    end
  end

  def test_get_object_info_json_parse_called
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     {"test" => "fake"},
                     ['{ "test": "fake" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, mock_json do
        @artifactory.get_object_info 'fake-object'
      end
    end
    assert_mock mock_json
  end

  def test_get_object_info_return_json_parse_result
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     {"test" => "fake-fake##"},
                     ['{ "test": "fake" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, mock_json do
        result = @artifactory.get_object_info 'fake-object'
        assert_equal({"test" => "fake-fake##"}, result)
      end
    end
  end

  def test_get_days_old_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryGemNotReady do
      artifactory.get_days_old '/fake'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_get_days_old_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :get,
                         :url => 'https://' + @artifactory.server +
                           '/artifactory/api/storage/' + @artifactory.repo_key + '/' + 'fake-object',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.get_days_old 'fake-object'
    end
    assert_mock mock_request
  end

  def test_get_days_old_return_negative_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404
    mock_response.expect :to_str, '{ "test": "fake" }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.get_days_old 'fake-object'
      assert_equal(-1, result)
    end
  end

  def test_get_days_old_json_parse_called
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     { "test" => "fake", "lastModified" => "2021-09-14T12:27:00.10" },
                     ['{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, mock_json do
        @artifactory.get_days_old 'fake-object'
      end
    end
    assert_mock mock_json
  end

  def test_get_days_old_call_time_with_last_updated
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'
    mock_time = Minitest::Mock.new
    mock_time.expect :call, Time.now, ['2021-09-14T12:27:00.10']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, { 'uri' => 'fake-host', 'lastModified' => '2021-09-14T12:27:00.10'} do
        Time.stub :iso8601, mock_time do
          @artifactory.get_days_old 'fake-object'
        end
      end
    end
    assert_mock mock_time
  end

  def test_get_days_old_call_time_now
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'
    mock_time = Minitest::Mock.new
    mock_time.expect :call, Time.now, []

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, { 'uri' => 'fake-host', 'lastModified' => '2021-09-14T12:27:00.10'} do
        Time.stub :now, mock_time do
          @artifactory.get_days_old 'fake-object'
        end
      end
    end
    assert_mock mock_time
  end

  def test_get_days_old_return_days_subtract
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 200
    mock_response.expect :to_str, '{ "test": "fake", "lastModified": "2021-09-14T12:27:00.10" }'

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      JSON.stub :parse, { 'uri' => 'fake-host', 'lastModified' => '2021-09-14T12:27:00.10'} do
        Time.stub :iso8601, (Time.now - (20*24*60*60)) do
          result = @artifactory.get_days_old 'fake-object'
          assert_equal 20, result
        end
      end
    end
  end

  def test_delete_object_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryGemNotReady do
      artifactory.delete_object 'fake-object'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_delete_object_call_get_api
    mock_request = Minitest::Mock.new
    mock_request.expect :call,
                        true,
                        [:method => :delete,
                         :url => 'https://' + @artifactory.server +
                           '/artifactory/' + @artifactory.repo_key + '/' + 'fake-object',
                         :user => @artifactory.user, :password => @artifactory.password]

    RestClient::Request.stub :execute, mock_request do
      @artifactory.delete_object 'fake-object'
    end
    assert_mock mock_request
  end

  def test_delete_object_return_nil_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.delete_object 'fake-object'
      refute result
    end
  end

  def test_delete_object_return_object_deleted
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 204
    mock_response.expect :to_str, '{ "test": "fake" }'
    mock_json = Minitest::Mock.new
    mock_json.expect :call,
                     {"test" => "fake"},
                     ['{ "test": "fake" }']

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.delete_object 'fake-object'
      assert result
    end
  end
end



