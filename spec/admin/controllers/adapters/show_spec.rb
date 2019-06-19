# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Adapters::Show do
  let(:action) { Admin::Controllers::Adapters::Show.new }
  let(:params) { Hash[] }
  let(:auth) { { username: 'admin', password: 'pass' } }
  let(:session) { { user_id: Login.new.call(auth).user&.id } }

  # it 'is successful' do
  #   response = action.call(params)
  #   response[0].must_equal 200
  # end
end
