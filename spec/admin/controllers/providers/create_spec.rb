# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::Create do
  let(:action) { Admin::Controllers::Providers::Create.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new(client: '::1').call(auth).user&.id }
  let(:auth) { {username: 'admin', password: 'pass'} }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'redirect setup' do
      response = action.call(params.merge(
                               provider: {
                                 name: 'test',
                                 display_name: 'テスト',
                                 adapter_name: 'dummy',
                               }))
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/admin/setup'
    end
  end
end
