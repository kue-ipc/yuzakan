require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::Create do
  let(:action) { Admin::Controllers::Providers::Create.new }
  let(:params) { {
    'rack.session' => session,
    provider: {
      name: 'test',
      display_name: 'テスト',
      adapter_name: 'dummy',
    },
  } }
  let(:auth) { { username: 'admin', password: 'pass' } }
  let(:session) { { user_id: Authenticate.new.call(auth).user&.id } }

  describe 'before initialized' do
    before do
      db_clear
    end

    after do
      db_reset
    end

    it 'redirect setup' do
      response = action.call(params)
      response[0].must_equal 302
      response[1]['Location'].must_equal '/admin/setup'
    end
  end

  # it 'redirect setup before initialized' do
  #   db_clear
  #   response = action.call(params)
  #   response[0].must_equal 302
  #   response[1]['Location'].must_equal '/admin/setup'
  # end
  #
  # it 'redirect new_session before login after initialized' do
  #   # let(:session) { {} }
  #   response = action.call(params)
  #   response[0].must_equal 302
  #   response[1]['Location'].must_equal '/admin/session/new'
  # end
  #
  # it 'is successful' do
  #   response = action.call(params)
  #   response[0].must_equal 302
  #   response[1]['Location'].must_equal '/admin/providers'
  # end
end
