require 'test_helper'

class RoombotsControllerTest < ActionController::TestCase
  setup do
    @roombot = roombots(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create roombot" do
    assert_difference('Roombot.count') do
      post :create, roombot: { location: @roombot.location, name: @roombot.name }
    end

    assert_redirected_to roombot_path(assigns(:roombot))
  end

  test "should show roombot" do
    get :show, id: @roombot
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @roombot
    assert_response :success
  end

  test "should update roombot" do
    put :update, id: @roombot, roombot: { location: @roombot.location, name: @roombot.name }
    assert_redirected_to roombot_path(assigns(:roombot))
  end

  test "should destroy roombot" do
    assert_difference('Roombot.count', -1) do
      delete :destroy, id: @roombot
    end

    assert_redirected_to roombots_path
  end
end
