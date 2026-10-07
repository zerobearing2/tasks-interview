class MakeTasksCompleteRequired < ActiveRecord::Migration[8.1]
  def change
    reversible do |direction|
      direction.up { execute "UPDATE tasks SET complete = FALSE WHERE complete IS NULL" }
    end

    change_column_default :tasks, :complete, from: nil, to: false
    change_column_null :tasks, :complete, false
  end
end
