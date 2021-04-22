require "test_helper"

class ProposalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @proposal = proposals(:one)
  end

  test "should get index" do
    get proposals_url, as: :json
    assert_response :success
  end

  test "should create proposal" do
    assert_difference('Proposal.count') do
      post proposals_url, params: { proposal: { professor_id: @proposal.professor_id, rute_document: @proposal.rute_document, student_id: @proposal.student_id, summary: @proposal.summary, title: @proposal.title, topic_id: @proposal.topic_id, topic_name: @proposal.topic_name } }, as: :json
    end

    assert_response 201
  end

  test "should show proposal" do
    get proposal_url(@proposal), as: :json
    assert_response :success
  end

  test "should update proposal" do
    patch proposal_url(@proposal), params: { proposal: { professor_id: @proposal.professor_id, rute_document: @proposal.rute_document, student_id: @proposal.student_id, summary: @proposal.summary, title: @proposal.title, topic_id: @proposal.topic_id, topic_name: @proposal.topic_name } }, as: :json
    assert_response 200
  end

  test "should destroy proposal" do
    assert_difference('Proposal.count', -1) do
      delete proposal_url(@proposal), as: :json
    end

    assert_response 204
  end
end
