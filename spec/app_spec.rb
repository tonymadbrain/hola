require File.expand_path '../spec_helper.rb', __FILE__

describe "API" do

  context 'GET /v1/tasks' do
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

  context 'POST /v1/tasks' do
    it 'change count of tasks in DB' do
      expect { post '/api/v1/tasks', { name: "New task" } }.to change(Task, :count).by(1)
    end

    it 'create right task in DB' do
      post '/api/v1/tasks', { name: "New task" }
      expect(Task.first).to eq('New task')
    end
  end
end
