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

  test "create saves the task and redirects to the index" do
    log_in_as users(:ada)

    assert_difference -> { Task.count }, 1 do
      post tasks_path, params: {task: {title: "Book hotel in Kyoto", description: "Ryokan near Gion"}}
    end

    assert_redirected_to tasks_path
    assert_equal "Ryokan near Gion", Task.find_by!(title: "Book hotel in Kyoto").description
  end

  test "create with a blank title re-renders the index with the error" do
    log_in_as users(:ada)

    assert_no_difference -> { Task.count } do
      post tasks_path, params: {task: {title: "", description: "Ryokan near Gion"}}
    end

    assert_response :unprocessable_entity
    assert_select "li", text: "Title can't be blank"
    assert_select "textarea", text: "Ryokan near Gion"
    assert_select "h2", text: tasks(:book_flights).title
    assert_select "h2", text: tasks(:renew_passport).title
  end

  test "update saves the changes and redirects to the index" do
    log_in_as users(:ada)
    task = tasks(:renew_passport)

    patch task_path(task), params: {task: {title: "Renew passport (expedited)"}}

    assert_redirected_to tasks_path
    assert_equal "Renew passport (expedited)", task.reload.title
  end

  test "update with a blank title re-renders the edit form with the error" do
    log_in_as users(:ada)
    task = tasks(:renew_passport)

    patch task_path(task), params: {task: {title: "", description: "Changed"}}

    assert_response :unprocessable_entity
    assert_select "li", text: "Title can't be blank"
    assert_select "form[action=?]", task_path(task)
    task.reload
    assert_equal "Renew passport", task.title
    assert_equal "Current one expires in under six months.", task.description
  end
end
