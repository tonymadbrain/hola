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
end

get "/" do
  # @tasks = Task.order("created_at DESC")
  # # @tasks = Task.all
  # redirect "/new" if @tasks.empty?
  # json @tasks
  # # slim :index, layout: :layout
  status 200
end

get "/new" do
  slim :new, layout: :layout
end

namespace '/api/v1' do
  get '/tasks' do
    @tasks = Task.all
    json @tasks
  end
end

post "/new" do
  @task = Task.new(name: params['name'])
  @task.save!
  # if @task.save
  #   json @task
  # else
  #   status 400
  #   # body json @task.error.message
  # end
end

get "/task/:id" do
  if @task = Task.find_by_id(params[:id])
    slim :task, layout: :layout
  else
    return 404
  end
end
