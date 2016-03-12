require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'
require 'docdsl'

register Sinatra::DocDsl

# some meta data for documentation page (optional)
page do
  title "Hola API docs"
  introduction "REST API for simple taskmanager Hola"
  footer "[Github](https://github.com/tonymadbrain/hola_api)"
  configure_renderer do
    self.render_md
  end
end

def json_error(msg="Problem with backend", status=500)
  Rack::Response.new(
    [{'error': {'status': status, 'message': msg}}.to_json],
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
  documentation "Respond with list of existed tasks" do
    param :limit, "limit of tasks for response, default is 20, max is 100"
    param :offset, "offset for tasks, default is 0"
    header 'X-Total-Count', "provided header with count of tasks"
    response "", {"id":1,
      "name":"MyTask",
      "description":"some useful description",
      "state":"new",
      "created_at":"2016-03-11T12:28:01.380Z",
      "updated_at":"2016-03-11T12:28:01.380Z"
    }
    status 200,"If all work properly"
    status 400
    status 404
  end
  get '/tasks' do
    params[:limit] ||= 20
    params[:offset] ||= 0
    params[:limit] = params[:limit].to_i
    params[:offset] = params[:offset].to_i

    if params[:limit] < 0 or params[:limit] > 100
      return json_error "Invalid limit", 400
    end

    if params[:offset] < 0
      return json_error "Invalid offset", 400
    end

    if @tasks = Task.limit(params[:limit]).offset(params[:offset])
      @tasks_sount = Task.count
      headers['X-Total-Count'] = "#{@tasks_sount}"
      #need implement header 'Link'
      json @tasks
    else
      json_error
    end
  end

  documentation "Create new task" do
    payload "Required fields name and description",
      {"name":"MyTask", "description":"some useful description"}
    response "Response with created object", {"id":1,
      "name":"MyTask",
      "description":"some useful description",
      "state":"new",
      "created_at":"2016-03-11T20:05:44.192Z",
      "updated_at":"2016-03-11T20:05:44.192Z"
    }
    status 201
    status 400
    status 404
  end
  post '/tasks' do
    params = JSON.parse(request.env["rack.input"].read)
    @task = Task.new(name: params['name'], description: params['description'])
    if @task.save
      status 201
      json @task
    else
      json_error(@task.errors.full_messages[0], 400)
    end
  end

  documentation "Not allowed to change bach of tasks for now" do
    status 405
  end
  put '/tasks' do
    status 405
  end

  documentation "Delete all existed task" do
    status 202
    status 400
  end
  delete '/tasks' do
    if Task.destroy_all()
      status 202
    else
      status 400
    end
  end

  documentation "Respond with selected task" do
    param :id, "numeric id"
    response "Response with task", {"id":2,
      "name":"MyTask",
      "description":"some useful description",
      "state":"new",
      "created_at":"2016-03-11T20:05:44.192Z",
      "updated_at":"2016-03-11T20:05:44.192Z"
    }
    status 200
    status 400
    status 404
  end
  get '/tasks/:id' do
    # params = JSON.parse(request.env["rack.input"].read)
    if @task = Task.find_by_id(params[:id])
      json @task
    else
      # status 404
      json_error("Not found", 404)
    end
  end

  documentation "Just nope!" do
    status 405
  end
  post '/tasks/:id' do
    status 405
  end

  documentation "Change selected task" do
    param :id, "numeric id"
    payload "Required fields name and description",
      {"name":"MySuperTask", "description":"some useful description", "state":"in progress"}
    response "Response with updated task", {"id":2,
      "name":"MySuperTask",
      "description":"some useful description",
      "state":"in progress",
      "created_at":"2016-03-11T20:05:44.192Z",
      "updated_at":"2016-03-11T20:05:44.192Z"
    }
    status 202
    status 400
    status 404
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
      json_error(@task.errors.full_messages[0], 400)
    end
  end

  documentation "Delete selected task" do
    param :id, "numeric id"
    status 202
    status 400
    status 404
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

not_found do
  json_error("Doesn't know this ditty", 404)
end

doc_endpoint "/doc"
