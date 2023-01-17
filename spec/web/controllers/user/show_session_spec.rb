# frozen_string_literal: true

RSpec.describe Web::Controllers::User::Show, type: :action do
  # let(:action)  { Web::Controllers::User::Show.new }
  # let(:params)  { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  # let(:session) { {user_id: user_id, access_time: Time.now} }
  # let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  # let(:auth)    { {username: 'user', password: 'word'} }

  # it 'is successful' do
  #   response = action.call(params)
  #   expect(response[0]).to eq 200
  #   expect(action.send(:client).to_s).to eq '::1'
  # end

  # RSpec.describe 'admin login' do
  #   let(:auth) { {username: 'admin', password: 'pass'} }

  #   it 'is successful' do
  #     response = action.call(params)
  #     expect(response[0]).to eq 200
  #   end
  # end

  # RSpec.describe 'session timeout' do
  #   let(:session) { {user_id: user_id, access_time: Time.now - (24 * 60 * 60)} }

  #   it 'redirect login with flash' do
  #     response = action.call(params)
  #     flash = action.exposures[:flash]
  #     expect(response[0]).to eq 302
  #     expect(response[1]['Location']).to eq '/'
  #     expect(flash[:warn]).to eq 'セッションがタイムアウトしました。'
  #   end
  # end

  # RSpec.describe 'no usner_id' do
  #   let(:session) { {access_time: Time.now} }

  #   it 'redirect login' do
  #     response = action.call(params)
  #     flash = action.exposures[:flash]
  #     expect(response[0]).to eq 302
  #     expect(response[1]['Location']).to eq '/'
  #     expect(flash[:warn]).to eq 'ログインしてください。'
  #   end
  # end

  # RSpec.describe 'no access_time' do
  #   let(:session) { {user_id: user_id} }

  #   it 'redirect login' do
  #     response = action.call(params)
  #     flash = action.exposures[:flash]
  #     expect(response[0]).to eq 302
  #     expect(response[1]['Location']).to eq '/'
  #     expect(flash[:warn]).to eq 'ログインしてください。'
  #   end
  # end

  # RSpec.describe 'no session' do
  #   let(:session) { {} }

  #   it 'redirect login' do
  #     response = action.call(params)
  #     flash = action.exposures[:flash]
  #     expect(response[0]).to eq 200
  #     expect(response[1]['Location']).to eq '/'
  #     expect(flash[:warn]).to eq 'ログインしてください。'
  #   end
  # end

  # RSpec.describe 'short 1min timeout' do
  #   before { UpdateConfig.new.call(session_timeout: 60) }
  #   after { db_reset }

  #   describe '10 sec' do
  #     let(:session) { {user_id: user_id, access_time: Time.now - 10} }

  #     it 'is successful' do
  #       response = action.call(params)
  #       expect(response[0]).to eq 200
  #     end
  #   end

  #   describe '120 sec' do
  #     let(:session) { {user_id: user_id, access_time: Time.now - 120} }

  #     it 'redirect login' do
  #       response = action.call(params)
  #       flash = action.exposures[:flash]
  #       expect(response[0]).to eq 200
  #       expect(flash[:warn]).to eq 'セッションがタイムアウトしました。'
  #     end
  #   end
  # end
end
