# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Admin::Controllers::Config::New do
  let(:action) { Admin::Controllers::Config::New.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval

  it 'rediret to root' do
    response = action.call(params)
    expect(response[0]).must_equal 302
    expect(response[1]['Location']).must_equal '/'
  end

  describe 'before initialized' do
    let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { nil } } }

    it 'is successful' do
      response = action.call(params)
      expect(response[0]).must_equal 200
    end
  end
end
