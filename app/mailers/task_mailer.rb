class TaskMailer < ApplicationMailer
  def due_reminder(task)
    @task = task

    mail to: task.assignee.email, subject: %("#{task.title}" is due tomorrow)
  end
end
