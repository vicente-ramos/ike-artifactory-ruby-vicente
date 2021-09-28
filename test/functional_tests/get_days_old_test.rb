require 'test_helper'

class GetDaysOldFunctionalTest < IKEArtifactoryTestBase

  def test_get_days_old_is_integer
    result = @artifactory.get_days_old '/ib'
    assert_instance_of Integer, result
  end

  def test_get_days_old_value
    result = @artifactory.get_days_old '/ib'
    assert result > 120
  end
end


