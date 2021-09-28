require 'test_helper'

class EvaluateContainerImageFunctionalTest < IKEArtifactoryTestBase

  def test_keeps_user_branch
    image = 'ib/syncer'
    tag = '0.5.6'
    production_images = %w[0.5.0 0.5.1 0.5.2 0.5.3 0.5.4 0.5.5 0.5.6]
    assert @artifactory.evaluate_container_image image, tag, production_images, 30
  end

end



