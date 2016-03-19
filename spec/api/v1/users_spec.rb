# require File.expand_path '../../../spec_helper.rb', __FILE__
#
# describe 'Users API' do
#   describe 'GET /users' do
#     context 'when have users' do
#       before do
#         User.create(email:'user1@hola.api', password: 'user1@hola.api')
#         User.create(email:'user2@hola.api', password: 'user2@hola.api')
#         get '/api/v1/users'
#       end
#
#       it 'provide header X-Total-Count' do
#         expect(last_response.headers['X-Total-Count']).to eq("#{User.count}")
#       end
#
#       it 'respond with 200 ok' do
#         expect(last_response).to be_ok
#       end
#
#       it 'respond with right objects' do
#         data = JSON::parse(last_response.body)
#         expect(data.size).to eq(2)
#         expect(data[0]['email']).to eq('user1@hola.api')
#         expect(data[1]['email']).to eq('user2@hola.api')
#       end
#     end
#   end
# end
