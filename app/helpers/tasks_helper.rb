module TasksHelper
  def assignable_users
    User.order(:name)
  end

  def assignee_name(task)
    task.assignee ? task.assignee.name : "Unassigned"
  end

  def due_date(task)
    l(task.due_on, format: :long) if task.due_on
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
