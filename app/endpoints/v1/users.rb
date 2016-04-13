namespace '/api/v1' do
  documentation "Respond with list of existed users" do
    param :limit, "limit of users for response, default is 20, max is 100"
    param :offset, "offset for users, default is 0"
    response "", {
      "id":1,
      "name":"MyTask",
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
end
