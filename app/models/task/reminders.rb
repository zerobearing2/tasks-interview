class Task::Reminders
  def self.deliver = new.deliver

  def deliver
    Task.due_for_reminder.includes(:assignee).find_each do |task|
      Rails.error.handle { remind(task) }
    end
  end

  private

  def remind(task)
    TaskMailer.due_reminder(task).deliver_now
    # Skips validation: a legacy title-less row would fail to save after its email went out, then be emailed again every run.
    task.update_column(:reminded_for, task.due_on)
  end
end
