require "test_helper"

class TaskMailerTest < ActionMailer::TestCase
  test "due_reminder tells the assignee what is due and links to the task" do
    task = Task.create!(
      title: "Book hotel in Kyoto",
      description: "Ryokan near Gion",
      due_on: Date.new(2026, 5, 4),
      assignee: users(:ada)
    )

    mail = TaskMailer.due_reminder(task)

    assert_equal ["ada@tern.travel"], mail.to
    assert_equal %("Book hotel in Kyoto" is due tomorrow), mail.subject
    [mail.html_part, mail.text_part].each do |part|
      body = part.body.to_s
      assert_includes body, "Book hotel in Kyoto"
      assert_includes body, "May 04, 2026"
      assert_includes body, "Ryokan near Gion"
      assert_includes body, "http://example.com/tasks/#{task.id}/edit"
    end
  end
end
