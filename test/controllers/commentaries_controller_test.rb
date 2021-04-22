require "test_helper"

class CommentariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @commentary = commentaries(:one)
  end

  test "should get index" do
    get commentaries_url, as: :json
    assert_response :success
  end

  test "should create commentary" do
    assert_difference('Commentary.count') do
      post commentaries_url, params: { commentary: { issuer_date: @commentary.issuer_date, issuer_id: @commentary.issuer_id, message: @commentary.message, state: @commentary.state } }, as: :json
    end

    assert_response 201
  end

  test "should show commentary" do
    get commentary_url(@commentary), as: :json
    assert_response :success
  end

  test "should update commentary" do
    patch commentary_url(@commentary), params: { commentary: { issuer_date: @commentary.issuer_date, issuer_id: @commentary.issuer_id, message: @commentary.message, state: @commentary.state } }, as: :json
    assert_response 200
  end

  test "should destroy commentary" do
    assert_difference('Commentary.count', -1) do
      delete commentary_url(@commentary), as: :json
    end

    assert_response 204
  end
end
