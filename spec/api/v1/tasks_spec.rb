require File.expand_path '../../../spec_helper.rb', __FILE__

describe "Tasks API" do
  describe 'GET /tasks' do
    context 'when have tasks' do
      before do
        Task.create(name:'Task 1', description: 'description')
        Task.create(name:'Task 2', description: 'description')
        get '/api/v1/tasks'
      end

      it 'respond with 200 ok' do
        expect(last_response).to be_ok
      end

      it 'respond with right objects' do
        data = JSON::parse(last_response.body)
        expect(data.size).to eq(2)
        expect(data[0]['name']).to eq('Task 1')
        expect(data[1]['name']).to eq('Task 2')
      end
    end

    context 'when have no tasks' do
      before do
        get '/api/v1/tasks'
      end

      it 'return 200' do
        expect(last_response).to be_ok
      end

      it 'return empty array' do
        data = JSON::parse(last_response.body)
        expect(data.size).to eq(0)
      end
    end
  end

  describe 'POST /tasks' do
    context 'valid task' do
      it 'change count of tasks in database' do
        expect { do_request "New task" }.to change(Task, :count).by(1)
      end

      it 'create new task in database' do
        do_request "New task 2"
        expect(Task.first.name).to eq('New task 2')
      end

      it 'respond with 201' do
        do_request "New task"
        expect(last_response.status).to eq 201
      end

      it 'return new entity' do
        do_request "New task"
        data = JSON::parse(last_response.body)
        expect(data['name']).to eq('New task')
      end
    end

    context 'invalid task' do
      it 'not change count of tasks in database' do
        expect { do_request "" }.to_not change(Task, :count)
      end

      it 'respond with 400' do
        do_request ""
        expect(last_response.status).to eq 400
      end

      # need refactor this test in future
      it 'respond with json error' do
        do_request ""
        data = JSON::parse(last_response.body)
        expect(data['error']).to be
      end
    end

    def do_request(name)
      post '/api/v1/tasks', { name: name, description: "description" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    end
  end

  describe 'PUT /tasks' do
    it 'return 405 for now' do
      put '/api/v1/tasks', { name: "New name for task", description: 'new description' }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(last_response.status).to eq 405
    end
  end

  describe 'DELETE /tasks' do
    before do
      Task.create(name:'Task 1', description: 'description')
      Task.create(name:'Task 2', description: 'description')
      delete '/api/v1/tasks'
    end

    it 'respond with 202' do
      expect(last_response.status).to eq 202
    end

    it 'delete all tasks' do
      expect(Task.count).to eq 0
    end
  end

  describe 'GET /tasks/:id' do
    context 'when task exist' do
      before do
        Task.create(name:'Super task', description: 'Super description')
        get '/api/v1/tasks/1'
      end

      it 'respond with 200 ok' do
        expect(last_response).to be_ok
      end

      it 'respond with right object' do
        data = JSON::parse(last_response.body)
        expect(data['name']).to eq('Super task')
        expect(data['description']).to eq('Super description')
      end
    end

    context 'when task do not exist' do
      before do
        get '/api/v1/tasks/999'
      end

      it 'respond with 404' do
        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'POST /tasks/:id' do
    before do
      Task.create(name:'Super task', description: 'Super description')
      post '/api/v1/tasks/1'
    end

    it 'respond with 405' do
      expect(last_response.status).to eq 405
    end
  end

  describe 'PUT /tasks/:id' do
    context 'with valid data' do
      before do
        Task.create(name:'Task for changes', description: 'Description for changes')
        put '/api/v1/tasks/1', { name: "New name for task", description: 'New description' }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end

      it 'respond with 202' do
        expect(last_response.status).to eq 202
      end

      it 'return new task' do
        data = JSON::parse(last_response.body)
        expect(data['name']).to eq('New name for task')
        expect(data['description']).to eq('New description')
      end
    end

    context 'with not valid data' do
      it 'respond with 400' do
        Task.create(name:'Task for changes', description: 'Description for changes')
        put '/api/v1/tasks/1', { name: "123", description: '456' }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
      end
    end

    context 'if task does not exist' do
      it 'respond with 404' do
        put '/api/v1/tasks/1', { name: "123", description: '456' }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 404
      end
    end
  end

  describe 'DELETE /tasks/:id' do
    context 'when task exist' do
      before do
        Task.create(name:'Task for deleting', description: 'Description for task deleting')
      end

      it 'delete task form database' do
        expect { do_request }.to change(Task, :count).by(-1)
      end

      it 'respond with 202' do
        do_request
        expect(last_response.status).to eq 202
      end
    end

    context 'when task does not exist' do
      it 'respond with 404' do
        do_request
        expect(last_response.status).to eq 404
      end
    end

    def do_request
      delete '/api/v1/tasks/1', {}.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    end
  end
end
