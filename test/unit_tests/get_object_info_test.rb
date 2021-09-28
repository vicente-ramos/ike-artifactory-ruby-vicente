require 'test_helper'

class UnitTestGetObjectInfo < IKEArtifactoryTestBase

  def test_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryGemNotReady do
      artifactory.get_object_info 'fake-object'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_call_get_api
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

  def test_return_nil_if_fail
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

  def test_json_parse_called
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

  def test_return_json_parse_result
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

end



