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

      # subject { @user }

      it 'provide header X-Total-Count' do
        expect(last_response.headers['X-Total-Count']).to eq("#{User.count}")
      end

      it 'respond with 200 ok' do
        expect(last_response).to be_ok
      end

      it 'respond with right objects' do
        data = JSON::parse(last_response.body)
        expect(data.size).to eq(User.count)
        expect(data[0]['email']).to eq('user1@hola.api')
      end

      %w(id email created_at updated_at).each do |attr|
        it "contains #{ attr }" do
          data = JSON::parse(last_response.body)
          expect(data[0]["#{attr}"].to_json).to eq(@user.send(attr.to_sym).to_json)
        end
      end

      %w(password_digest admin).each do |attr|
        it "does not contain #{ attr }" do
          data = JSON::parse(last_response.body)
          # expect(last_response.body).to_not have_json_path(attr)
          expect(data[0]["#{attr}"].to_json).to eq("null")
        end
      end
    end
  end
end
