require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/namespace'
require 'json'
require 'docdsl'

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

register Sinatra::DocDsl

# specify some meta data for your documentation page (optional)
page do
  title "Hola API docs"
  header ""
  introduction "REST API for simple taskmanager Hola"
  # useful if your sinatra app lives under some context path other than /.
  # Causes the paths in the documentation to be prefixed with
  # this. Defaults to empty
  # url_prefix "/my/application/path"
  footer "# End of API docs
  [Github](https://github.com/tonymadbrain/hola_api)"
  # configuring the renderer is optional, and in this case just uses the default
  configure_renderer do
    # if you use the provided render_md, you can use markdown in your documentation.
    #This uses a simple markdown template to render an html page using kramdown
    self.render_md

    # if you want to get at the raw markdown
    # self.md

    # we have a json renderer as well, uncomment to enable
    # self.json

    # finally, we have a simple html template that does not rely on markdown
    # self.html

    # Of course, you can easily write your own renderer. It is executed on
    # the @page_doc object and you have full access to the attributes in there.
    # be sure to return a valid sinatra response, e.g. [200,'hello wrld']
  end
end

def json_error(msg, status=500)
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
    @tasks = Task.all
    json @tasks
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
