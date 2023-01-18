# frozen_string_literal: true

RSpec.describe Admin::Controllers::Users::Show, type: :action do
  init_controller_spec
  let(:action) { Admin::Controllers::Users::Show.new(**action_opts) }
end
