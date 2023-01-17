# frozen_string_literal: true

RSpec.describe Admin::Controllers::Config::Edit do
  init_controller_spec(self)
  let(:action) { Admin::Controllers::Config::Edit.new(**action_opts) }
end
