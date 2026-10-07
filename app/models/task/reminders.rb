class Task::Reminders
  class Error < StandardError; end

  def self.deliver = new.deliver

  def deliver
    failed = Task.due_for_reminder.includes(:assignee).find_each.count { |task| !remind(task) }

    raise Error, "#{failed} #{"reminder".pluralize(failed)} failed to send" if failed.positive?
  end

  private

  def remind(task)
    TaskMailer.due_reminder(task).deliver_now
    # Skips validation: a legacy title-less row would fail to save after its email went out, then be emailed again every run.
    task.update_column(:reminded_for, task.due_on)
  rescue => error
    # Rails.error has no subscriber in this app, so the log is the only trace of a failed send.
    Rails.logger.error("Reminder for task #{task.id} failed: #{error.class}: #{error.message}")
    Rails.error.report(error, context: {task_id: task.id})
    false
  end
end
