# frozen_string_literal: true

RSpec.describe Web::Controllers::User::Password::Edit, type: :action do
  init_controller_spec(self)
  let(:action) { Web::Controllers::User::Password::Edit.new(**action_opts) }
end
