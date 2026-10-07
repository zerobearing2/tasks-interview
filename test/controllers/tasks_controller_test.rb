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

  test "index shows each task's assignee" do
    log_in_as users(:ada)

    get tasks_path

    assert_select "div", text: users(:grace).name
    assert_select "div", text: "Unassigned"
  end

  test "index does not run a query per task" do
    log_in_as users(:ada)
    baseline = count_queries { get tasks_path }

    4.times do |number|
      assignee = User.create!(name: "Assignee #{number}", email: "assignee#{number}@tern.travel", password: "abc123")
      Task.create!(title: "Task #{number}", assignee:)
    end

    assert_equal baseline, count_queries { get tasks_path }
  end

  test "index offers to mark each task as the opposite of its current state" do
    log_in_as users(:ada)

    get tasks_path

    assert_toggle_button tasks(:book_flights), label: "Mark incomplete", complete: "false"
    assert_toggle_button tasks(:renew_passport), label: "Mark complete", complete: "true"
  end

  test "update with only complete marks an incomplete task complete" do
    log_in_as users(:ada)
    task = tasks(:renew_passport)

    patch task_path(task), params: {task: {complete: "true"}}

    assert_redirected_to tasks_path
    assert task.reload.complete?
    assert_equal "Renew passport", task.title
  end

  test "update with only complete marks a complete task incomplete" do
    log_in_as users(:ada)
    task = tasks(:book_flights)

    patch task_path(task), params: {task: {complete: "false"}}

    assert_redirected_to tasks_path
    assert_not task.reload.complete?
  end

  test "a toggled task keeps its place in the index" do
    log_in_as users(:ada)
    first, second = Task.order(:id).to_a

    patch task_path(first), params: {task: {complete: !first.complete?}}
    follow_redirect!

    assert_equal [first.title, second.title], css_select("h2").map(&:text)
  end

  test "toggling a task that has no title shows the title error" do
    log_in_as users(:ada)
    task = Task.new(title: nil, complete: false)
    task.save!(validate: false)

    patch task_path(task), params: {task: {complete: "true"}}

    assert_response :unprocessable_content
    assert_select "li", text: "Title can't be blank"
    assert_not task.reload.complete?
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

    assert_response :unprocessable_content
    assert_select "li", text: "Title can't be blank"
    assert_select "textarea", text: "Ryokan near Gion"
    assert_select "h2", text: tasks(:book_flights).title
    assert_select "h2", text: tasks(:renew_passport).title
  end

  test "create assigns the task" do
    log_in_as users(:ada)

    assert_difference -> { Task.where(assignee: users(:grace)).count }, 1 do
      post tasks_path, params: {task: {title: "Book hotel in Kyoto", assignee_id: users(:grace).id}}
    end

    assert_redirected_to tasks_path
  end

  test "create with a nonexistent assignee re-renders the index with the error" do
    log_in_as users(:ada)

    assert_no_difference -> { Task.count } do
      post tasks_path, params: {task: {title: "Book hotel in Kyoto", assignee_id: nonexistent_user_id}}
    end

    assert_response :unprocessable_content
    assert_select "li", text: "Assignee must exist"
    assert_select "input[name='task[title]'][value='Book hotel in Kyoto']"
  end

  test "create with a non-numeric assignee is rejected" do
    log_in_as users(:ada)

    assert_no_difference -> { Task.count } do
      post tasks_path, params: {task: {title: "Book hotel in Kyoto", assignee_id: "abc"}}
    end

    assert_response :unprocessable_content
    assert_select "li", text: "Assignee must exist"
  end

  test "edit offers every user and preselects the current assignee" do
    log_in_as users(:ada)

    get edit_task_path(tasks(:book_flights))

    assert_select "label[for='task_assignee_id']", text: "Assignee"
    assert_select "select[name='task[assignee_id]']" do
      assert_select "option[value='']", text: "Unassigned"
      assert_select "option[value='#{users(:ada).id}']", text: users(:ada).name
      assert_select "option[selected][value='#{users(:grace).id}']", text: users(:grace).name
    end
  end

  test "update assigns the task" do
    log_in_as users(:ada)

    patch task_path(tasks(:renew_passport)), params: {task: {assignee_id: users(:ada).id}}

    assert_redirected_to tasks_path
    assert_equal users(:ada), tasks(:renew_passport).reload.assignee
  end

  test "update with a blank assignee un-assigns the task" do
    log_in_as users(:ada)

    patch task_path(tasks(:book_flights)), params: {task: {assignee_id: ""}}

    assert_redirected_to tasks_path
    assert_nil tasks(:book_flights).reload.assignee
  end

  test "update with a nonexistent assignee re-renders the edit form with the error" do
    log_in_as users(:ada)

    patch task_path(tasks(:book_flights)), params: {task: {assignee_id: nonexistent_user_id}}

    assert_response :unprocessable_content
    assert_select "li", text: "Assignee must exist"
    assert_equal users(:grace), tasks(:book_flights).reload.assignee
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

    assert_response :unprocessable_content
    assert_select "li", text: "Title can't be blank"
    assert_select "form[action=?]", task_path(task)
    task.reload
    assert_equal "Renew passport", task.title
    assert_equal "Current one expires in under six months.", task.description
  end

  test "index shows a task's due date and leaves it blank when there is none" do
    log_in_as users(:ada)
    tasks(:renew_passport).update!(due_on: Date.new(2026, 5, 3))

    get tasks_path

    assert_select "div", text: "May 03, 2026", count: 1
    assert_select "div", text: /\A\w+ \d{2}, \d{4}\z/, count: 1
  end

  test "the form offers a due date field" do
    log_in_as users(:ada)
    tasks(:renew_passport).update!(due_on: Date.new(2026, 5, 3))

    get edit_task_path(tasks(:renew_passport))

    assert_select "label[for='task_due_on']", text: "Due on"
    assert_select "input[type=date][name='task[due_on]'][value='2026-05-03']"
  end

  test "create saves the due date" do
    log_in_as users(:ada)

    post tasks_path, params: {task: {title: "Book hotel in Kyoto", due_on: "2026-05-03"}}

    assert_redirected_to tasks_path
    assert_equal Date.new(2026, 5, 3), Task.find_by!(title: "Book hotel in Kyoto").due_on
  end

  test "create with a blank due date saves the task without one" do
    log_in_as users(:ada)

    post tasks_path, params: {task: {title: "Book hotel in Kyoto", due_on: ""}}

    assert_redirected_to tasks_path
    assert_nil Task.find_by!(title: "Book hotel in Kyoto").due_on
  end

  test "create ignores reminded_for" do
    log_in_as users(:ada)

    post tasks_path, params: {task: {title: "Book hotel in Kyoto", reminded_for: "2026-05-03"}}

    assert_nil Task.find_by!(title: "Book hotel in Kyoto").reminded_for
  end

  test "update saves the due date" do
    log_in_as users(:ada)

    patch task_path(tasks(:renew_passport)), params: {task: {due_on: "2026-05-03"}}

    assert_redirected_to tasks_path
    assert_equal Date.new(2026, 5, 3), tasks(:renew_passport).reload.due_on
  end

  test "update with a blank due date clears it" do
    log_in_as users(:ada)
    tasks(:renew_passport).update!(due_on: Date.new(2026, 5, 3))

    patch task_path(tasks(:renew_passport)), params: {task: {due_on: ""}}

    assert_redirected_to tasks_path
    assert_nil tasks(:renew_passport).reload.due_on
  end

  test "destroy deletes the task and redirects to the index" do
    log_in_as users(:ada)

    assert_difference -> { Task.count }, -1 do
      delete task_path(tasks(:renew_passport))
    end

    assert_redirected_to tasks_path
  end

  test "destroy that fails keeps the task and shows an alert" do
    log_in_as users(:ada)
    task = tasks(:renew_passport)

    assert_no_difference -> { Task.count } do
      task.stub(:destroy, false) do
        Task.stub(:find, task) do
          delete task_path(task)
        end
      end
    end

    assert_redirected_to tasks_path
    follow_redirect!
    assert_select "[role=alert]", text: "Task could not be deleted."
  end

  private

  def nonexistent_user_id
    User.maximum(:id) + 1
  end

  def count_queries(&block)
    count = 0
    counter = ->(*, payload) { count += 1 unless payload[:name].in?(%w[SCHEMA TRANSACTION]) }
    ActiveSupport::Notifications.subscribed(counter, "sql.active_record", &block)
    count
  end

  def assert_toggle_button(task, label:, complete:)
    assert_select "form[action=?]", task_path(task) do
      assert_select "input[name=_method][value=patch]"
      assert_select "input[name=?][value=?]", "task[complete]", complete
      assert_select "button", text: label
    end
  end
end
