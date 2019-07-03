require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::Update do
  let(:action) { Admin::Controllers::Providers::Update.new }
  let(:params) { Hash['rack.session' => session] }
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

  # before do
  #   db_reset
  # end
  #
  # it 'redirect setup before initialized' do
  #   db_clear
  #   response = action.call(params)
  #   response[0].must_equal 302
  #   response[1]['Location'].must_equal '/admin/setup'
  # end
  #
  # it 'redirect new_session before login after initialized' do
  #   response = action.call(params)
  #   response[0].must_equal 302
  #   response[1]['Location'].must_equal '/admin/session/new'
  # end

  # it 'is successful after initialized' do
  #   response = action.call(params)
  #   response[0].must_equal 200
  # end
end
