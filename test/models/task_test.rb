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
end
