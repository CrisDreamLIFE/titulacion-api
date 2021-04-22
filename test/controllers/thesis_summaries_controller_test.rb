require "test_helper"

class ThesisSummariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @thesis_summary = thesis_summaries(:one)
  end

  test "should get index" do
    get thesis_summaries_url, as: :json
    assert_response :success
  end

  test "should create thesis_summary" do
    assert_difference('ThesisSummary.count') do
      post thesis_summaries_url, params: { thesis_summary: { dias_rev: @thesis_summary.dias_rev, program_id: @thesis_summary.program_id, semester: @thesis_summary.semester, status: @thesis_summary.status, thesis_id: @thesis_summary.thesis_id, thype_id: @thesis_summary.thype_id, topic_id: @thesis_summary.topic_id, year: @thesis_summary.year } }, as: :json
    end

    assert_response 201
  end

  test "should show thesis_summary" do
    get thesis_summary_url(@thesis_summary), as: :json
    assert_response :success
  end

  test "should update thesis_summary" do
    patch thesis_summary_url(@thesis_summary), params: { thesis_summary: { dias_rev: @thesis_summary.dias_rev, program_id: @thesis_summary.program_id, semester: @thesis_summary.semester, status: @thesis_summary.status, thesis_id: @thesis_summary.thesis_id, thype_id: @thesis_summary.thype_id, topic_id: @thesis_summary.topic_id, year: @thesis_summary.year } }, as: :json
    assert_response 200
  end

  test "should destroy thesis_summary" do
    assert_difference('ThesisSummary.count', -1) do
      delete thesis_summary_url(@thesis_summary), as: :json
    end

    assert_response 204
  end
end
