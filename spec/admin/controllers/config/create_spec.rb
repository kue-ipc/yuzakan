# frozen_string_literal: true

require_relative '../../../spec_helper'

describe Admin::Controllers::Config::Create do
  let(:action) { Admin::Controllers::Config::Create.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval

  it 'rediret to root' do
    response = action.call(params)
    _(response[0]).must_equal 302
    _(response[1]['Location']).must_equal '/'
  end

  # describe 'before initialized' do
  #   before do
  #     db_clear
  #   end
  
  #   after do
  #     db_clear
  #   end
  
  #   let(:config_repository) { ConfigRepository.new.tap { |obj| stub(obj).current { nil } } }

  #   it 'is successful' do
  #     response = action.call(params)
  #     flash = action.exposures[:flash]

  #     _(response[0]).must_equal 200
  #     _(flash[:errors]).must_be_empty
  #   end
  # end
end
