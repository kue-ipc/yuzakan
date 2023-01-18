# frozen_string_literal: true

RSpec.describe Web::Controllers::Providers::Show, type: :action do
  init_controller_spec
  let(:action) { Web::Controllers::Providers::Show.new(**action_opts) }

  # it 'is successful' do
  #   response = action.call(params)
  #   expect(response[0]).to eq 200
  # end
end
