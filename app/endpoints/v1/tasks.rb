namespace '/api/v1' do
  documentation "Respond with list of existed tasks" do
    param :limit, "limit of tasks for response, default is 20, max is 100"
    param :offset, "offset for tasks, default is 0"
    response "", {"id":1,
      "name":"MyTask",
      "description":"some useful description",
      "state":"new",
      "user_id":1,
      "created_at":"2016-03-11T12:28:01.380Z",
      "updated_at":"2016-03-11T12:28:01.380Z"
    }
    status 200
    status 400
    status 404
  end
  get '/tasks' do
    params[:limit] ||= 20
    params[:offset] ||= 0
    limit = params[:limit].to_i
    offset = params[:offset].to_i

    if limit < 0 or limit > 100
      return json_error "Invalid limit", 400
    end

    if offset < 0
      return json_error "Invalid offset", 400
    end

    if @tasks = Task.limit(limit).offset(offset)
      tasks_count = Task.count
      headers['X-Total-Count'] = "#{tasks_count}"
      link = ""
      url = request.url.split('?').first
      offset_first = 0
      link += "<#{url}?offset=#{offset_first}&limit=#{limit}>; rel=\"first\","
      offset_last = tasks_count - limit
      link += "<#{url}?offset=#{offset_last}&limit=#{limit}>; rel=\"last\","
      offset_next = offset + limit
      link += "<#{url}?offset=#{offset_next}&limit=#{limit}>; rel=\"next\","
      if offset != 0
        if offset >= limit
          offset_prev = offset - limit
          link += "<#{url}?offset=#{offset_prev}&limit=#{limit}>; rel=\"prev\","
        end
        if offset < limit
          offset_prev = 0
          limit = offset
          link += "<#{url}?offset=#{offset_prev}&limit=#{limit}>; rel=\"prev\","
        end
      end
      headers['Link'] = link
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
    params = JSON.parse(request.body.read).symbolize_keys
    user = User.find(params[:user])
    @task = user.tasks.new(params.except(:user))
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
      "user_id":1,
      "created_at":"2016-03-11T20:05:44.192Z",
      "updated_at":"2016-03-11T20:05:44.192Z"
    }
    status 200
    status 400
    status 404
  end
  get '/tasks/:id' do
    if @task = Task.find_by_id(params[:id])
      json @task
    else
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
