class TasksController < ApplicationController
  before_action :authenticate_user
  before_action :set_tasks, only: [:index, :create]

  def index
    @task = Task.new
  end

  def edit
    @task = Task.find(params[:id])
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      redirect_to tasks_path
    else
      render :index, status: :unprocessable_content
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      redirect_to tasks_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @task = Task.find(params[:id])

    if @task.destroy
      redirect_to tasks_path
    else
      redirect_to tasks_path, alert: "Task could not be deleted."
    end
  end

  private

  def set_tasks
    @tasks = Task.includes(:assignee).order(:id)
    @due_soon_tasks = Task.due_soon.where(assignee: current_user).includes(:assignee).order(:due_on, :id)
  end

  def task_params
    params.require(:task).permit(:title, :description, :complete, :assignee_id, :due_on)
  end
end
