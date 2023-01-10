# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Home::Index do
  # describe 'session' do
  #   let(:action) { Admin::Controllers::Home::Index.new }
  #   let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  #   let(:session) { {user_id: user_id, access_time: Time.now} }
  #   let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  #   let(:auth) { {username: 'admin', password: 'pass'} }

  #   it 'is successful' do
  #     response = action.call(params)
  #     _(response[0]).must_equal 200
  #   end

  #   describe 'no usner_id' do
  #     let(:session) { {access_time: Time.now} }

  #     it 'redirect login' do
  #       response = action.call(params)
  #       flash = action.exposures[:flash]
  #       _(response[0]).must_equal 302
  #       _(response[1]['Location']).must_equal '/'
  #       _(flash[:warn]).must_equal 'ログインしてください。'
  #     end
  #   end

  #   describe 'no access_time' do
  #     let(:session) { {user_id: user_id} }

  #     it 'redirect login' do
  #       response = action.call(params)
  #       flash = action.exposures[:flash]
  #       _(response[0]).must_equal 302
  #       _(response[1]['Location']).must_equal '/'
  #       _(flash[:warn]).must_equal 'ログインしてください。'
  #     end
  #   end

  #   describe 'no session' do
  #     let(:session) { {} }

  #     it 'redirect login' do
  #       response = action.call(params)
  #       flash = action.exposures[:flash]
  #       _(response[0]).must_equal 302
  #       _(response[1]['Location']).must_equal '/'
  #       _(flash[:warn]).must_equal 'ログインしてください。'
  #     end
  #   end

  #   describe 'session timeout' do
  #     let(:session) { {user_id: user_id, access_time: Time.now - (24 * 60 * 60)} }

  #     it 'redirect login' do
  #       response = action.call(params)
  #       flash = action.exposures[:flash]
  #       _(response[0]).must_equal 302
  #       _(response[1]['Location']).must_equal '/'
  #       _(flash[:warn]).must_equal 'セッションがタイムアウトしました。'
  #     end
  #   end

  #   describe 'short 1min timeout' do
  #     before { UpdateConfig.new.call(session_timeout: 60) }
  #     after { db_reset }

  #     describe '10 sec' do
  #       let(:session) { {user_id: user_id, access_time: Time.now - 10} }

  #       it 'is successful' do
  #         response = action.call(params)
  #         _(response[0]).must_equal 200
  #       end
  #     end

  #     describe '120 sec' do
  #       let(:session) { {user_id: user_id, access_time: Time.now - 120} }

  #       it 'redirect login' do
  #         response = action.call(params)
  #         flash = action.exposures[:flash]
  #         _(response[0]).must_equal 302
  #         _(response[1]['Location']).must_equal '/'
  #         _(flash[:warn]).must_equal 'セッションがタイムアウトしました。'
  #       end
  #     end
  #   end
  # end
end
