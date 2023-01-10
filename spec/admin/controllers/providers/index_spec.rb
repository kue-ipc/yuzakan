# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Providers::Index do
  let(:action) { Admin::Controllers::Providers::Index.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval

  it 'is failure' do
    response = action.call(params)
    _(response[0]).must_equal 403
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
    end
  end

  describe 'redirect no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      _(response[0]).must_equal 302
      _(response[1]['Location']).must_equal '/'
    end
  end
end
