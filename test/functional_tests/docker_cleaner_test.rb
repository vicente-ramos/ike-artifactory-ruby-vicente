require 'test_helper'

class DockerCleanerClassTest < Minitest::Test

  def test_can_create_object
    IKE::Artifactory::DockerCleaner.new(
      repo_uri: 'avvo-docker-local.artifactory.internetbrands.com',
      repo_name: 'avvo/amos',
      days_old: 30,
      images_exclude_list: %w[fake1 fake2]
    )
  end

end
