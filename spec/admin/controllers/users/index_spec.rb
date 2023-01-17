# frozen_string_literal: true

RSpec.describe Admin::Controllers::Users::Index, type: :action do
  init_controller_spec(self)
  let(:action) { Admin::Controllers::Users::Index.new(**action_opts) }
end
