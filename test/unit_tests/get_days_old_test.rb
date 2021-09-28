require 'test_helper'
require 'time'

class UnitTestGetDaysOld < IKEArtifactoryTestBase

  def test_raise_not_ready
    artifactory = IKE::Artifactory::Client.new()
    exception = assert_raises IKE::Artifactory::IKEArtifactoryGemNotReady do
      artifactory.get_days_old '/fake'
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
      @artifactory.get_days_old 'fake-object'
    end
    assert_mock mock_request
  end

  def test_return_negative_if_fail
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

  def test_json_parse_called
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

  def test_call_time_with_last_updated
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

  def test_call_time_now
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

  def test_return_days_subtract
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

end

