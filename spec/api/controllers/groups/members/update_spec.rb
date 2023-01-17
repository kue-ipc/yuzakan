# frozen_string_literal: true

RSpec.describe Api::Controllers::Groups::Members::Update do
  init_controller_spec(self)
  let(:action) { Api::Controllers::Groups::Members::Update.new(**action_opts) }
  let(:format) { 'application/json' }

  # it 'is successful' do
  #   response = action.call(params)
  #   expect(response[0]).to eq 200
  # end
end
