# frozen_string_literal: true

RSpec.describe Api::Controllers::Groups::Index, type: :action do
  init_controller_spec
  let(:action) { Api::Controllers::Groups::Index.new(**action_opts) }
  let(:format) { 'application/json' }
end
