# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Setup::Show do
  let(:action) { Admin::Controllers::Setup::Show.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval

  it 'is successful' do
    response = action.call(params)
    _(response[0]).must_equal 200
  end

  describe 'before initialized' do
    let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { nil } } }

    it 'is successful' do
      response = action.call(params)
      _(response[0]).must_equal 200
    end
  end
end
