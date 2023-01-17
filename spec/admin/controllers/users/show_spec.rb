# frozen_string_literal: true

RSpec.describe Admin::Controllers::Users::Show do
  init_controller_spec(self)
  let(:action) { Admin::Controllers::Users::Show.new(**action_opts) }
end
