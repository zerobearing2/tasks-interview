class TaskMailerPreview < ActionMailer::Preview
  def due_reminder
    TaskMailer.due_reminder(Task.where.associated(:assignee).where.not(due_on: nil).first!)
  end
end
