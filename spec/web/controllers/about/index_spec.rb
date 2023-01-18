# frozen_string_literal: true

RSpec.describe Web::Controllers::About::Index, type: :action do
  init_controller_spec
  let(:action) { Web::Controllers::About::Index.new(**action_opts) }
end
