require "test_helper"

class ActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @activity = activities(:one)
  end

  test "should get index" do
    get activities_url, as: :json
    assert_response :success
  end

  test "should create activity" do
    assert_difference('Activity.count') do
      post activities_url, params: { activity: { close_date: @activity.close_date, end_date: @activity.end_date, start_date: @activity.start_date, state: @activity.state, tareas_pendientes: @activity.tareas_pendientes, tareas_realizadas: @activity.tareas_realizadas, title: @activity.title } }, as: :json
    end

    assert_response 201
  end

  test "should show activity" do
    get activity_url(@activity), as: :json
    assert_response :success
  end

  test "should update activity" do
    patch activity_url(@activity), params: { activity: { close_date: @activity.close_date, end_date: @activity.end_date, start_date: @activity.start_date, state: @activity.state, tareas_pendientes: @activity.tareas_pendientes, tareas_realizadas: @activity.tareas_realizadas, title: @activity.title } }, as: :json
    assert_response 200
  end

  test "should destroy activity" do
    assert_difference('Activity.count', -1) do
      delete activity_url(@activity), as: :json
    end

    assert_response 204
  end
end
