class Task < ApplicationRecord
  belongs_to :assignee, class_name: "User", optional: true

  validates :title, presence: true
  validates :assignee, presence: {message: :required}, unless: -> { assignee_id.nil? }
end
