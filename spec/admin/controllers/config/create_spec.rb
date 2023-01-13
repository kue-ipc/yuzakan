# frozen_string_literal: true

require_relative '../../../spec_helper'

RSpec.describe Admin::Controllers::Config::Create do
  let(:action) { Admin::Controllers::Config::Create.new(**action_opts) }
  eval(init_let_script) # rubocop:disable Security/Eval

  it 'rediret to root' do
    response = action.call(params)
    expect(response[0]).to eq 302
    expect(response[1]['Location']).to eq '/'
  end

  # RSpec.describe 'before initialized' do
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

  #     expect(response[0]).to eq 200
  #     expect(flash[:errors]).to be_empty
  #   end
  # end
end
