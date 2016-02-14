require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require "sinatra/json"

class Task < ActiveRecord::Base
end

get "/" do
  @tasks = Task.order("created_at DESC")
  # @tasks = Task.all
  redirect "/new" if @tasks.empty?
  json @tasks
  # slim :index, layout: :layout
end

get "/new" do
  slim :new, layout: :layout
end

post "/new" do
  @task = Task.new(name: params['name'])
  if @task.save
    redirect "task/#{@task.id}"
  else
    slim :new, layout: :layout
  end
end

get "/task/:id" do
  if @task = Task.find_by_id(params[:id])
    slim :task, layout: :layout
  else
    return 404
  end
end
