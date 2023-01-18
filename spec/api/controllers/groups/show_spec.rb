# frozen_string_literal: true

RSpec.describe Api::Controllers::Groups::Show, type: :action do
  init_controller_spec
  let(:action) { Api::Controllers::Groups::Show.new(**action_opts) }
  let(:format) { 'application/json' }
end
