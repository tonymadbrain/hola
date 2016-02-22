require File.expand_path '../../../spec_helper.rb', __FILE__

describe "Tasks API" do
  describe 'GET /tasks' do
    context 'when have tasks' do
      before do
        Task.create(name:'Task 1', description: 'desc')
        Task.create(name:'Task 2', description: 'desc')
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
    end

    def do_request(name)
      post '/api/v1/tasks', { name: name, description: "desc" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
    end
  end

  describe 'PUT /tasks' do
    it 'return 405 for now' do
      put '/api/v1/tasks', { name: "New name for task", description: 'new desc' }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      expect(last_response.status).to eq 405
    end
  end

  describe 'DELETE /tasks' do
    before do
      Task.create(name:'Task 1', description: 'desc')
      Task.create(name:'Task 2', description: 'desc')
      delete '/api/v1/tasks'
    end

    it 'respond with 202' do
      expect(last_response.status).to eq 202
    end

    it 'delete all tasks' do
      expect(Task.count).to eq 0
    end
  end
end
