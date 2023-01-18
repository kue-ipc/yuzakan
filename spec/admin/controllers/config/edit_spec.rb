# frozen_string_literal: true

RSpec.describe Admin::Controllers::Config::Edit, type: :action do
  init_controller_spec
  let(:action) { Admin::Controllers::Config::Edit.new(**action_opts) }
end
