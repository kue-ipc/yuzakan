# frozen_string_literal: true

RSpec.describe Api::Controllers::Groups::Show do
  init_controller_spec(self)
  let(:action) { Api::Controllers::Groups::Show.new(**action_opts) }
  let(:format) { 'application/json' }
end
