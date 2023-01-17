# frozen_string_literal: true

RSpec.describe Api::Controllers::Groups::Index do
  init_controller_spec(self)
  let(:action) { Api::Controllers::Groups::Index.new(**action_opts) }
  let(:format) { 'application/json' }
end
