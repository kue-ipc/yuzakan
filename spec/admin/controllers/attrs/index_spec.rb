# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Admin::Controllers::Attrs::Index do
  let(:action) { Admin::Controllers::Attrs::Index.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval

  it 'is failure' do
    response = action.call(params)
    expect(response[0]).to eq 403
  end

  describe 'admin' do
    let(:user) { User.new(id: 1, name: 'admin', display_name: '管理者', email: 'admin@example.jp', clearance_level: 5) }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).to eq 200
    end
  end

  describe 'no login session' do
    let(:session) { {uuid: uuid} }

    it 'is error' do
      response = action.call(params)
      expect(response[0]).to eq 302
      expect(response[1]['Location']).to eq '/'
    end
  end
end
