class TaskMailerPreview < ActionMailer::Preview
  def due_reminder
    TaskMailer.due_reminder(Task.joins(:assignee).find_by!(due_on: Date.current + 1))
  end
end
