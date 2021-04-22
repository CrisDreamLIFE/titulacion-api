require "test_helper"

class WorkPlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @work_plan = work_plans(:one)
  end

  test "should get index" do
    get work_plans_url, as: :json
    assert_response :success
  end

  test "should create work_plan" do
    assert_difference('WorkPlan.count') do
      post work_plans_url, params: { work_plan: { actividades_pendientes: @work_plan.actividades_pendientes, actividades_realizadas: @work_plan.actividades_realizadas, state: @work_plan.state, suscription: @work_plan.suscription } }, as: :json
    end

    assert_response 201
  end

  test "should show work_plan" do
    get work_plan_url(@work_plan), as: :json
    assert_response :success
  end

  test "should update work_plan" do
    patch work_plan_url(@work_plan), params: { work_plan: { actividades_pendientes: @work_plan.actividades_pendientes, actividades_realizadas: @work_plan.actividades_realizadas, state: @work_plan.state, suscription: @work_plan.suscription } }, as: :json
    assert_response 200
  end

  test "should destroy work_plan" do
    assert_difference('WorkPlan.count', -1) do
      delete work_plan_url(@work_plan), as: :json
    end

    assert_response 204
  end
end
