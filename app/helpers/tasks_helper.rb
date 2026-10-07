module TasksHelper
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
