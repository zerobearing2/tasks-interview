require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "valid with a title" do
    assert Task.new(title: "Book hotel in Kyoto").valid?
  end

  test "incomplete by default" do
    assert_equal false, Task.create!(title: "Book hotel in Kyoto").complete
  end

  test "invalid without a title" do
    task = Task.new(title: nil)

    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "invalid with a whitespace-only title" do
    task = Task.new(title: "   ")

    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "valid with an existing assignee" do
    assert Task.new(title: "Book hotel in Kyoto", assignee_id: users(:ada).id).valid?
  end

  test "invalid when the assignee does not exist" do
    task = Task.new(title: "Book hotel in Kyoto", assignee_id: User.maximum(:id) + 1)

    assert_not task.valid?
    assert_includes task.errors[:assignee], "must exist"
  end

  test "invalid when the assignee id is zero" do
    assert_not Task.new(title: "Book hotel in Kyoto", assignee_id: 0).valid?
  end

  test "due_soon covers incomplete tasks due from today through seven days out" do
    travel_to Time.utc(2026, 5, 3, 12) do
      overdue = Task.create!(title: "Overdue", due_on: Date.new(2026, 5, 2))
      today = Task.create!(title: "Due today", due_on: Date.new(2026, 5, 3))
      seventh_day = Task.create!(title: "Due in 7 days", due_on: Date.new(2026, 5, 10))
      eighth_day = Task.create!(title: "Due in 8 days", due_on: Date.new(2026, 5, 11))
      completed = Task.create!(title: "Completed", due_on: Date.new(2026, 5, 4), complete: true)

      due_soon = Task.due_soon

      assert_includes due_soon, today
      assert_includes due_soon, seventh_day
      assert_not_includes due_soon, overdue
      assert_not_includes due_soon, eighth_day
      assert_not_includes due_soon, completed
      assert_not_includes due_soon, tasks(:renew_passport)
    end
  end
end
