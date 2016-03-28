require File.expand_path '../../../spec_helper.rb', __FILE__

describe 'Users API' do
  describe 'GET /users' do
    context 'when have users' do
      before do
        @user = User.new(
          email:'user1@hola.api',
          password: 'user1@hola.api',
          name: "Test User"
        )
        @user.save
        get '/api/v1/users'
      end

      it 'provide header X-Total-Count' do
        expect(last_response.headers['X-Total-Count']).to eq("#{User.count}")
      end

      it 'respond with 200 ok' do
        expect(last_response).to be_ok
      end

      %w(id email name created_at updated_at).each do |attr|
        it "respond contains #{ attr }" do
          data = JSON::parse(last_response.body)
          expect(data[0]["#{attr}"].to_json).to eq(@user.send(attr.to_sym).to_json)
        end
      end

      %w(password_digest admin).each do |attr|
        it "does not contain #{ attr }" do
          data = JSON::parse(last_response.body)
          expect(data[0]).to_not have_key("#{attr}")
        end
      end
    end

    context 'when have no users' do
      before do
        get '/api/v1/users'
      end

      it 'return 200' do
        expect(last_response).to be_ok
      end

      it 'return empty array' do
        data = JSON::parse(last_response.body)
        expect(data.size).to eq(0)
      end
    end

    context 'limit and offset params' do
      before do
        1...5.times { |i| User.create(email:"user_#{i+1}@hola.api", password: '123456') }
      end

      it 'provide link header when offset 0' do
        get '/api/v1/users', limit: 2, offset: 0
        expect(last_response.headers['Link']).to eq("<http://example.org/api/v1/users?offset=0&limit=2>; rel=\"first\",<http://example.org/api/v1/users?offset=3&limit=2>; rel=\"last\",<http://example.org/api/v1/users?offset=2&limit=2>; rel=\"next\",")
      end

      it 'provide link header when offset < limit' do
        get '/api/v1/users', limit: 2, offset: 1
        expect(last_response.headers['Link']).to eq("<http://example.org/api/v1/users?offset=0&limit=2>; rel=\"first\",<http://example.org/api/v1/users?offset=3&limit=2>; rel=\"last\",<http://example.org/api/v1/users?offset=3&limit=2>; rel=\"next\",<http://example.org/api/v1/users?offset=0&limit=1>; rel=\"prev\",")
      end

      it 'provide link header offset > limit' do
        get '/api/v1/users', limit: 1, offset: 2
        expect(last_response.headers['Link']).to eq("<http://example.org/api/v1/users?offset=0&limit=1>; rel=\"first\",<http://example.org/api/v1/users?offset=4&limit=1>; rel=\"last\",<http://example.org/api/v1/users?offset=3&limit=1>; rel=\"next\",<http://example.org/api/v1/users?offset=1&limit=1>; rel=\"prev\",")
      end

      it 'return 3 when limit 3 and users count 5' do
        get '/api/v1/users', limit: 3

        data = JSON::parse(last_response.body)
        expect(data.size).to eq(3)
      end

      it 'return user with id 5 when offset 4 and limit 1' do
        get '/api/v1/users', limit: 1, offset: 4

        data = JSON::parse(last_response.body)
        expect(data.size).to eq(1)
        expect(data[0]['id']).to eq(5)
      end

      it 'respond with error when limit < 0' do
        get '/api/v1/users', limit: -5
        expect(last_response.status).to eq 400
      end

      it 'respond with error when offset < 0' do
        get '/api/v1/users', offset: -5
        expect(last_response.status).to eq 400
      end

      it 'respond with error when limit > 100' do
        get '/api/v1/users', limit: 101
        expect(last_response.status).to eq 400
      end
    end

    describe 'POST /users' do
      context 'valid user' do
        it 'change count of users in database' do
          expect { do_request "new_user@hola.api" }.to change(User, :count).by(1)
        end

        it 'create new user in database' do
          do_request "new_user_2@hola.api"
          expect(User.first.email).to eq('new_user_2@hola.api')
        end

        it 'respond with 201' do
          do_request "new_user@hola.api"
          expect(last_response.status).to eq 201
        end

        it 'return new entity' do
          do_request "new_user@hola.api"
          data = JSON::parse(last_response.body)
          expect(data['email']).to eq('new_user@hola.api')
        end
      end

      context 'invalid task' do
        it 'not change count of users in database' do
          expect { do_request "" }.to_not change(User, :count)
        end

        it 'respond with 400' do
          do_request ""
          expect(last_response.status).to eq 400
        end

        it 'respond with json object error' do
          do_request ""
          data = JSON::parse(last_response.body)
          expect(data).to have_key('error')
        end
      end

      def do_request(email)
        post '/api/v1/users',
          { email: email, password: "123456" }.to_json,
          { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
      end
    end
  end
end
