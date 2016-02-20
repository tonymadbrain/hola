require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/namespace'

# module JsonExceptions

#   def self.registered(app)
#     app.set show_exceptions: false

#     app.error { |err|
#       Rack::Response.new(
#         [{'error' => err.message}.to_json],
#         500,
#         {'Content-type' => 'application/json'}
#       ).finish
#     }
#   end
# end

# register JsonExceptions

class Task < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 25 }
  # validates :description, presence: true, length: { maximum: 1400 }
  after_initialize :init

  def init
    self.state  ||= 'new'           #will set the default value only if it's nil
  end
end

namespace '/api/v1' do
  get '/tasks' do
    @tasks = Task.all
    json @tasks
  end

  post '/tasks' do
    # params = JSON.parse(params[:name], symbolize_names: true)
    # json params
    # @task = Task.new(name: params['name'], description: params['description'])
    @task = Task.new(name: params['name'])
    if @task.save
      json @task
    else
      status 400
      json "Can't create new task"
    end
  end
end

get "/task/:id" do
  if @task = Task.find_by_id(params[:id])
    json @task
  else
    return 404
  end
end
