module TasksHelper
  def assignable_users
    User.order(:name)
  end

  def assignee_name(task)
    task.assignee ? task.assignee.name : "Unassigned"
  end

  def complete_toggle_button(task)
    button_to(
      task.complete? ? "Mark incomplete" : "Mark complete",
      task_path(task),
      method: :patch,
      params: {task: {complete: !task.complete?}},
      class: "cursor-pointer"
    )
  end
end
