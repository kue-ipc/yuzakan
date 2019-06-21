# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Web::Controllers::Home::Index do
  let(:action) { Web::Controllers::Home::Index.new }
  let(:params) { Hash['rack.session' => session] }
  let(:auth) { { username: 'user', password: 'word' } }
  let(:session) { { user_id: Login.new.call(auth).user&.id,
                    access_time: Time.now } }

  it 'redirect to dashboard' do
    response = action.call(params)
    response[0].must_equal 302
    response[1]['Location'].must_equal '/dashboard'
  end

  describe 'before login' do
    let(:session) { {} }

    it 'is successful' do
      response = action.call(params)
      response[0].must_equal 200
    end
  end
end
