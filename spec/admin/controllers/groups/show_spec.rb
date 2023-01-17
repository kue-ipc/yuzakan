# frozen_string_literal: true

RSpec.describe Admin::Controllers::Groups::Show, type: :action do
  init_controller_spec(self)
  let(:action) { Admin::Controllers::Groups::Show.new(**action_opts) }
end
