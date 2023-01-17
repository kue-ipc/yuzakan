# frozen_string_literal: true

RSpec.describe Web::Controllers::User::Password::Update do
  init_controller_spec(self)
  let(:action) { Web::Controllers::User::Password::Update.new(**action_opts) }
end
