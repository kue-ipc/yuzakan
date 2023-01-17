# frozen_string_literal: true

RSpec.describe Web::Controllers::About::Browser, type: :action do
  init_controller_spec(self)
  let(:action) { Web::Controllers::About::Browser.new(**action_opts) }
end
