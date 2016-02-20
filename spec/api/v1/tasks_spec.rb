require File.expand_path '../../../spec_helper.rb', __FILE__

describe "Tasks API" do
  describe 'GET /tasks' do
    context 'when have tasks' do
      before do
        Task.create(name:'Task 1')
        Task.create(name:'Task 2')
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
        expect { post '/api/v1/tasks', { name: "New task" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }.to change(Task, :count).by(1)
      end

      it 'create new task in database' do
        post '/api/v1/tasks', { name: "New task 2" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(Task.first.name).to eq('New task 2')
      end

      it 'respond with 200' do
        post '/api/v1/tasks', { name: "New task" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response).to be_ok
      end

      it 'return new entity' do
        post '/api/v1/tasks', { name: "New task" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        data = JSON::parse(last_response.body)
        expect(data['name']).to eq('New task')
      end
    end

    context 'invalid task' do
      it 'not change count of tasks in database' do
        expect { post '/api/v1/tasks', { name: "" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }.to_not change(Task, :count)
      end

      it 'respond with 400' do
        post '/api/v1/tasks', { name: "" }.to_json, { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
        expect(last_response.status).to eq 400
      end
    end
  end
end
