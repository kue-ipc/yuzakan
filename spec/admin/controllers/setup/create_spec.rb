require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Create do
  let(:action) { Admin::Controllers::Setup::Create.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1', app: 'test').call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'is successful' do
      response = action.call(params.merge(
                               setup: {
                                 config: {
                                   title: 'テスト',
                                 },
                                 admin_user: {
                                   username: 'admin',
                                   password: 'pass',
                                   password_confirmation: 'pass',
                                 },
                               }))
      _(response[0]).must_equal 200
    end
  end

  describe 'after initialized' do
    it 'redirect setup done' do
      response = action.call(params.merge(
                               setup: {
                                 config: {
                                   title: 'テスト',
                                 },
                                 admin_user: {
                                   username: 'admin',
                                   password: 'pass',
                                   password_confirmation: 'pass',
                                 },
                               }))
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/admin/setup/done'
    end
  end
end
