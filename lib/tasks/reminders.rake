namespace :reminders do
  desc "Email assignees whose tasks are due tomorrow"
  task send: :environment do
    Task::Reminders.deliver
  end
end
