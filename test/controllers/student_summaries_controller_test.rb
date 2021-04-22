require "test_helper"

class StudentSummariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student_summary = student_summaries(:one)
  end

  test "should get index" do
    get student_summaries_url, as: :json
    assert_response :success
  end

  test "should create student_summary" do
    assert_difference('StudentSummary.count') do
      post student_summaries_url, params: { student_summary: { email: @student_summary.email, first_lastname: @student_summary.first_lastname, name: @student_summary.name, num_guias: @student_summary.num_guias, num_temas: @student_summary.num_temas, program_id: @student_summary.program_id, program_name: @student_summary.program_name, second_lastname: @student_summary.second_lastname, student_id: @student_summary.student_id, year_income: @student_summary.year_income } }, as: :json
    end

    assert_response 201
  end

  test "should show student_summary" do
    get student_summary_url(@student_summary), as: :json
    assert_response :success
  end

  test "should update student_summary" do
    patch student_summary_url(@student_summary), params: { student_summary: { email: @student_summary.email, first_lastname: @student_summary.first_lastname, name: @student_summary.name, num_guias: @student_summary.num_guias, num_temas: @student_summary.num_temas, program_id: @student_summary.program_id, program_name: @student_summary.program_name, second_lastname: @student_summary.second_lastname, student_id: @student_summary.student_id, year_income: @student_summary.year_income } }, as: :json
    assert_response 200
  end

  test "should destroy student_summary" do
    assert_difference('StudentSummary.count', -1) do
      delete student_summary_url(@student_summary), as: :json
    end

    assert_response 204
  end
end
