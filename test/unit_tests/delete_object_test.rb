require 'test_helper'

class UnitTestDeleteObject < IKEArtifactoryTestBase
  def test_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryGemNotReady do
      artifactory.delete_object 'fake-object'
    end
    assert_equal('Required attributes are missing. IKEArtifactoryGem not ready.', exception.message)
  end

  def test_call_get_api
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

  def test_return_nil_if_fail
    mock_response = Minitest::Mock.new
    mock_response.expect :code, 404

    RestClient::Request.stub :execute,
                             nil,
                             [mock_response, 'fake-request', 'fake-result'] do
      result = @artifactory.delete_object 'fake-object'
      refute result
    end
  end

  def test_return_object_deleted
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




