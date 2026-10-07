class TaskMailerPreview < ActionMailer::Preview
  def due_reminder
    TaskMailer.due_reminder(Task.joins(:assignee).where.not(due_on: nil).first!)
  end
end
