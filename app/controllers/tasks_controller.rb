class TasksController < ApplicationController
  before_action :authenticate_user

  def index
    @tasks = Task.all
  end

  def edit
    @task = Task.find(params[:id])
  end

  def create
    @task = Task.new(task_params)

    if @task.save
      redirect_to tasks_path
    else
      @tasks = Task.all
      render :index, status: :unprocessable_entity
    end
  end

  def update
    @task = Task.find(params[:id])

    if @task.update(task_params)
      redirect_to tasks_path
    else
      render :edit, status: :unprocessable_entity
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

  def task_params
    params.require(:task).permit(:title, :description, :complete)
  end
end
