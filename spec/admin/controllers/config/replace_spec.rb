# frozen_string_literal: true

RSpec.describe Admin::Controllers::Config::Replace do
  init_controller_spec(self)
  let(:action) { Admin::Controllers::Config::Replace.new(**action_opts) }

  # it 'is successful' do
  #   response = action.call(params)
  #   expect(response[0]).to eq 200
  # end
end
