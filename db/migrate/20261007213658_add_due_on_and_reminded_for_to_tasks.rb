class AddDueOnAndRemindedForToTasks < ActiveRecord::Migration[8.1]
  def change
    add_column :tasks, :due_on, :date
    add_index :tasks, :due_on
    add_column :tasks, :reminded_for, :date
  end
end
