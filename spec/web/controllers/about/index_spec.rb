# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Controllers::About::Index do
  let(:action) { Web::Controllers::About::Index.new }
  let(:params) { {'REMOTE_ADDR' => '::1', 'rack.session' => session} }
  let(:session) { {user_id: user_id, access_time: Time.now} }
  let(:user_id) { Authenticate.new.call(auth).user&.id }
  let(:auth) { {username: 'user', password: 'word'} }

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end

  describe 'can access' do
    describe 'before login' do
      let(:session) { {} }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
      end
    end

    describe 'before initialized' do
      before { db_clear }
      after { db_reset }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
      end
    end

    describe 'in maintenace' do
      before { UpdateConfig.new.call(maintenance: true) }
      after { db_reset }

      it 'is successful' do
        response = action.call(params)
        _(response[0]).must_equal 200
      end
    end
  end
end
