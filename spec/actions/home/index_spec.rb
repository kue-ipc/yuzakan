# frozen_string_literal: true

RSpec.describe Yuzakan::Actions::Home::Index do
  init_action_spec

  it "is successful" do
    warn user.attributes
    response = action.call(params)
    expect(response).to be_successful
  end
end
