namespace '/api/v1' do
  documentation "Respond with list of existed users" do
    param :limit, "limit of users for response, default is 20, max is 100"
    param :offset, "offset for users, default is 0"
    response "", {
      "id":1,
      "name":"MyUser",
      "email":"mail@example.org",
      "created_at":"2016-03-11T12:28:01.380Z",
      "updated_at":"2016-03-11T12:28:01.380Z"
    }
    status 200
    status 400
    status 404
  end
  get '/users' do
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

    if @users = User.limit(limit).offset(offset).select("id", "email", "name", "created_at", "updated_at")
      users_count = User.count
      headers['X-Total-Count'] = "#{users_count}"
      link = ""
      url = request.url.split('?').first
      offset_first = 0
      link += "<#{url}?offset=#{offset_first}&limit=#{limit}>; rel=\"first\","
      offset_last = users_count - limit
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
      json @users
    else
      json_error
    end
  end

  documentation "Create new user" do
    payload "Required fields email and password, field name is optional",
      {"name":"Andreyka Filonoff", "email":"nagibator2000@mail.ru", "password":"01042000"}
    response "Response with created object", {
      "id":2001,
      "name":"",
      "email":"nagibator2000@mail.ru",
      "created_at":"2016-03-11T12:28:01.380Z",
      "updated_at":"2016-03-11T12:28:01.380Z"
    }
    status 201
    status 400
    status 404
    status 405
  end
  post '/users' do
    if settings.production?
      return status 405 unless request.secure?
    end
    params = JSON.parse(request.body.read).symbolize_keys
    @user = User.new(params)
    if @user.save
      status 201
      json @user
    else
      json_error(@user.errors.full_messages[0], 400)
    end
  end

  documentation "Not allowed to change bach of users for now" do
    status 405
  end
  put '/users' do
    status 405
  end

  documentation "Delete all existed users" do
    status 202
    status 400
  end
  delete '/users' do
    if User.destroy_all()
      status 202
    else
      status 400
    end
  end

  documentation "Respond with selected user" do
    param :id, "Numeric id"
    response "Response with user", {
      "id":1,
      "name":"MyUser",
      "email":"mail@example.org",
      "created_at":"2016-03-11T12:28:01.380Z",
      "updated_at":"2016-03-11T12:28:01.380Z"
    }
    status 200
    status 400
    status 404
  end
  get '/users/:id' do
    if @user = User.where(id: "#{params[:id]}").select("id", "email", "name", "created_at", "updated_at").first
      headers['Link'] = "<http://" + request.host + "/api/v1/users/#{@user.id}/tasks>; rel=\"tasks\""
      json @user
    else
      json_error("Not found", 404)
    end
  end

  documentation "Just nope!" do
    status 405
  end
  post '/users/:id' do
    status 405
  end

  documentation "Change selected user" do
    param :id, "numeric id"
    payload "Password field is required",
      {"email":"mail@example.org", "password":"password", "name":"MyUser"}
    response "Only with status 202", {}
    status 202
    status 400
    status 404
  end
  put '/users/:id' do
    @user = User.find_by_id(params[:id])
    return status 404 if @user.nil?
    params = JSON.parse(request.body.read).symbolize_keys
    if @user.update(params)
      status 202
    else
      json_error(@user.errors.full_messages[0], 400)
    end
  end

  documentation "Delete selected user" do
    param :id, "numeric id"
    status 202
    status 400
    status 404
  end
  delete '/users/:id' do
    @user = User.find_by_id(params[:id])
    return status 404 if @user.nil?
    if @user.destroy
      status 202
    else
      status 400
    end
  end
end
