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
end
