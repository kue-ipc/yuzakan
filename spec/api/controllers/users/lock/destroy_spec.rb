# frozen_string_literal: true

RSpec.describe Api::Controllers::Users::Lock::Destroy, type: :action do
  init_controller_spec
  let(:action) { Api::Controllers::Users::Lock::Destroy.new(**action_opts) }
  let(:format) { 'application/json' }

  # it 'is successful' do
  #   response = action.call(params)
  #   expect(response[0]).to eq 200
  # end
end
