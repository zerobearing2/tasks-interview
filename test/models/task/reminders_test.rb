require "test_helper"

class Task::RemindersTest < ActiveSupport::TestCase
  include ActionMailer::TestHelper

  setup { travel_to Time.utc(2026, 5, 3, 12) }

  test "emails the assignee of a task due tomorrow and records the reminder" do
    task = Task.create!(title: "Book hotel in Kyoto", due_on: tomorrow, assignee: users(:ada))

    assert_emails(1) { Task::Reminders.deliver }

    assert_equal ["ada@tern.travel"], ActionMailer::Base.deliveries.last.to
    assert_equal %("Book hotel in Kyoto" is due tomorrow), ActionMailer::Base.deliveries.last.subject
    assert_equal tomorrow, task.reload.reminded_for
  end

  test "skips tasks that are completed, unassigned, or assigned to someone without an email" do
    no_email = User.create!(name: "No Email", email: nil, password: "abc123")
    empty_email = User.create!(name: "Empty Email", email: "", password: "abc123")
    Task.create!(title: "Completed", due_on: tomorrow, assignee: users(:ada), complete: true)
    Task.create!(title: "Unassigned", due_on: tomorrow)
    Task.create!(title: "No email", due_on: tomorrow, assignee: no_email)
    Task.create!(title: "Empty email", due_on: tomorrow, assignee: empty_email)

    assert_no_emails { Task::Reminders.deliver }

    assert_empty Task.where.not(reminded_for: nil)
  end

  test "skips tasks due today or in two days" do
    Task.create!(title: "Due today", due_on: tomorrow - 1, assignee: users(:ada))
    Task.create!(title: "Due in two days", due_on: tomorrow + 1, assignee: users(:ada))

    assert_no_emails { Task::Reminders.deliver }
  end

  test "sends nothing when run again" do
    Task.create!(title: "Book hotel in Kyoto", due_on: tomorrow, assignee: users(:ada))
    Task::Reminders.deliver

    assert_no_emails { Task::Reminders.deliver }
  end

  test "reminds again once the due date moves to a new tomorrow" do
    task = Task.create!(title: "Book hotel in Kyoto", due_on: tomorrow, assignee: users(:ada))
    Task::Reminders.deliver
    task.update!(due_on: tomorrow + 3)

    travel_to Time.utc(2026, 5, 6, 12) do
      assert_emails(1) { Task::Reminders.deliver }
    end

    assert_equal tomorrow + 3, task.reload.reminded_for
  end

  test "reminds once for a task that has no title" do
    task = Task.new(title: nil, due_on: tomorrow, assignee: users(:ada))
    task.save!(validate: false)

    assert_emails(1) { Task::Reminders.deliver }

    assert_equal tomorrow, task.reload.reminded_for
    assert_no_emails { Task::Reminders.deliver }
  end

  test "keeps going after a send fails and leaves the failed task to retry" do
    failing = Task.create!(title: "Fails to send", due_on: tomorrow, assignee: users(:ada))
    sending = Task.create!(title: "Sends", due_on: tomorrow, assignee: users(:grace))
    fail_for_ada = ->(mail) { raise "SMTP is down" if mail.to == ["ada@tern.travel"] }

    ActionMailer::Base.stub(:deliver_mail, fail_for_ada) do
      Task::Reminders.deliver
    end

    assert_nil failing.reload.reminded_for
    assert_equal tomorrow, sending.reload.reminded_for
    assert_emails(1) { Task::Reminders.deliver }
    assert_equal tomorrow, failing.reload.reminded_for
  end

  private

  def tomorrow
    Date.new(2026, 5, 4)
  end
end
