require 'test_helper'

class BasicBehaviorTest < Minitest::Test

  def test_setup_attributes
    artifactory = IKE::Artifactory::Client.new()
    artifactory.server = TEST_SERVER
    artifactory.repo_key = TEST_REPO_KEY
    artifactory.folder_path = TEST_FOLDER_PATH
  end

end
