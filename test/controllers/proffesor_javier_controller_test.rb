require "test_helper"

class ProffesorJavierControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get proffesor_javier_index_url
    assert_response :success
  end
end
