require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'

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

def json_error(msg, status)
  Rack::Response.new(
    [{'error' => msg}.to_json],
    status,
    {'Content-type' => 'application/json'}
  ).finish
end

class Task < ActiveRecord::Base
  validates :name, presence: true, length: { maximum: 25, minimum: 5 }
  validates :description, presence: true, length: { maximum: 1400, minimum: 10 }
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
    params = JSON.parse(request.env["rack.input"].read)
    @task = Task.new(name: params['name'], description: params['description'])
    # halt 201, {'Location' => "/messages/#{message.id}"}, ''
    if @task.save
      status 201
      json @task
    else
      json_error(@task.errors.full_messages[0], 400)
    end
  end

  put '/tasks' do
    status 405
  end

  delete '/tasks' do
    if Task.destroy_all()
      status 202
    else
      status 400
    end
  end

  get '/tasks/:id' do
    # params = JSON.parse(request.env["rack.input"].read)
    if @task = Task.find_by_id(params[:id])
      json @task
    else
      # return 404
      status 404
    end
  end

  post '/tasks/:id' do
    status 405
  end

  put '/tasks/:id' do
    @task = Task.find_by_id(params[:id])
    return status 404 if @task.nil?
    params = JSON.parse(request.env["rack.input"].read)
    @task.update(name: params['name'], description: params['description'])
    if @task.save
      status 202
      json @task
    else
      status 400
    end
  end

  delete '/tasks/:id' do
    @task = Task.find_by_id(params[:id])
    return status 404 if @task.nil?
    if @task.destroy
      status 202
    else
      status 400
    end
  end
end
