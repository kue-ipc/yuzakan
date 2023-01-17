# frozen_string_literal: true

RSpec.describe Web::Controllers::About::Index do
  init_controller_spec(self)
  let(:action) { Web::Controllers::About::Index.new(**action_opts) }
end
