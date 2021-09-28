require 'test_helper'

class GetObjectsInfoFunctionalTest < IKEArtifactoryTestBase

  def test_it_returns_a_hash
    result = @artifactory.get_object_info '/ib/syncer'
    assert_instance_of Hash, result
  end

  def test_contains_created_by
    result = @artifactory.get_object_info '/ib/syncer'
    assert_includes(result.keys, 'createdBy')
  end
end



