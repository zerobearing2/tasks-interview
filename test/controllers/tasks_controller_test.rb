require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  test "redirects to login when not authenticated" do
    get tasks_path

    assert_redirected_to new_session_path
  end

  test "index lists tasks" do
    log_in_as users(:ada)

    get tasks_path

    assert_response :success
    assert_select "h2", text: tasks(:book_flights).title
    assert_select "h2", text: tasks(:renew_passport).title
  end
end
