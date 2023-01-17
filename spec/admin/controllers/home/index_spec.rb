# frozen_string_literal: true

RSpec.describe Admin::Controllers::Home::Index, type: :action do
  init_controller_spec(self)
  let(:action) { Admin::Controllers::Home::Index.new(**action_opts) }
end
