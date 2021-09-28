require "test_helper"

class UnitTestEvaluateContainerImage < Minitest::Test

  def setup
    super
    @artifactory = IKE::Artifactory::Client.new()
    @artifactory.folder_path = 'ib'
  end

  def test_search_production_images
    mock_production_images = Minitest::Mock.new
    mock_production_images.expect :call,
                                  true,
                                  ['fake-tag']
    production_images = ['fake-tag', 'fake-prod']

    production_images.stub :include? , mock_production_images do
      @artifactory.evaluate_container_image 'fake-image',
                                            'fake-tag',
                                            production_images,
                                            30
    end
    assert_mock mock_production_images
  end

  def test_true_with_prod_image
    assert @artifactory.evaluate_container_image 'fake-image',
                                                   'fake-tag',
                                                   ['fake-tag', 'fake-prod'],
                                                   30
  end

  def test_call_get_days_old
    mock_get_days_old_mock = Minitest::Mock.new
    mock_get_days_old_mock.expect :call,
                                  14,
                                  ['ib/fake-image/fake-tag']
    @artifactory.stub :get_days_old, mock_get_days_old_mock do
      @artifactory.evaluate_container_image'fake-image',
                                           'fake-tag',
                                           ['fake-prod1', 'fake-prod2'],
                                           30
    end
    assert_mock mock_get_days_old_mock
  end

  def test_return_true_if_younger
    @artifactory.stub :get_days_old, 14 do
      result = @artifactory.evaluate_container_image'fake-image',
                                                    'fake-tag',
                                                    ['fake-prod1', 'fake-prod2'],
                                                    30
      assert result
    end
  end

  def test_return_true_if_older
    @artifactory.stub :get_days_old, 31 do
      result = @artifactory.evaluate_container_image'fake-image',
                                                    'fake-tag',
                                                    ['fake-prod1', 'fake-prod2'],
                                                    30
      refute result
    end
  end


end

