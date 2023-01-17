# frozen_string_literal: true

RSpec.describe Web::Controllers::Password::Edit do
  init_controller_spec(self)
  let(:action) { Web::Controllers::Password::Edit.new(**action_opts) }

  # it 'is successful' do
  #   response = action.call(params)
  #   expect(response[0]).to eq 200
  # end
end
