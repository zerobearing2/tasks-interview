class Task < ApplicationRecord
  belongs_to :assignee, class_name: "User", optional: true

  validates :title, presence: true
  validates :assignee, presence: {message: :required}, unless: -> { assignee_id.nil? }

  scope :due_soon, -> { where(complete: false, due_on: Date.current..Date.current + 7) }
  scope :due_for_reminder, -> {
    where(complete: false, due_on: Date.current + 1)
      .joins(:assignee)
      .where("TRIM(users.email) <> ''")
      .where("tasks.reminded_for IS DISTINCT FROM tasks.due_on")
  }
end
