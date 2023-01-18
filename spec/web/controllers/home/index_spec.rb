# frozen_string_literal: true

RSpec.describe Web::Controllers::Home::Index, type: :action do
  init_controller_spec
  let(:action) { Web::Controllers::Home::Index.new(**action_opts) }
end
