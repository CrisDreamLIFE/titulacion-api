require "test_helper"

class ProfessorSummariesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @professor_summary = professor_summaries(:one)
  end

  test "should get index" do
    get professor_summaries_url, as: :json
    assert_response :success
  end

  test "should create professor_summary" do
    assert_difference('ProfessorSummary.count') do
      post professor_summaries_url, params: { professor_summary: { academic: @professor_summary.academic, asignadas: @professor_summary.asignadas, avatar: @professor_summary.avatar, dias_rev_med: @professor_summary.dias_rev_med, email: @professor_summary.email, first_lastname: @professor_summary.first_lastname, grade: @professor_summary.grade, name: @professor_summary.name, num_tesis: @professor_summary.num_tesis, num_tesis_abandonadas: @professor_summary.num_tesis_abandonadas, num_tesis_med: @professor_summary.num_tesis_med, professor_id: @professor_summary.professor_id, second_lastname: @professor_summary.second_lastname, tiempo_final_med: @professor_summary.tiempo_final_med, topicos: @professor_summary.topicos } }, as: :json
    end

    assert_response 201
  end

  test "should show professor_summary" do
    get professor_summary_url(@professor_summary), as: :json
    assert_response :success
  end

  test "should update professor_summary" do
    patch professor_summary_url(@professor_summary), params: { professor_summary: { academic: @professor_summary.academic, asignadas: @professor_summary.asignadas, avatar: @professor_summary.avatar, dias_rev_med: @professor_summary.dias_rev_med, email: @professor_summary.email, first_lastname: @professor_summary.first_lastname, grade: @professor_summary.grade, name: @professor_summary.name, num_tesis: @professor_summary.num_tesis, num_tesis_abandonadas: @professor_summary.num_tesis_abandonadas, num_tesis_med: @professor_summary.num_tesis_med, professor_id: @professor_summary.professor_id, second_lastname: @professor_summary.second_lastname, tiempo_final_med: @professor_summary.tiempo_final_med, topicos: @professor_summary.topicos } }, as: :json
    assert_response 200
  end

  test "should destroy professor_summary" do
    assert_difference('ProfessorSummary.count', -1) do
      delete professor_summary_url(@professor_summary), as: :json
    end

    assert_response 204
  end
end
