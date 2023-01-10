# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Create do
  let(:action) { Admin::Controllers::Setup::Create.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval

  let(:action_params) {
    {
      setup: {
        config: {title: 'テスト'},
        admin_user: {username: 'admin', password: 'pass', password_confirmation: 'pass'},
      },
    }
  }

  it 'rediret to setup' do
    response = action.call(params)
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/admin/setup'
  end

  # describe 'before initialized' do
  #   let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { nil } } }

  #   it 'is successful' do
  #     response = action.call(params)
  #     _(response[0]).must_equal 200
  #   end
  # end
end
