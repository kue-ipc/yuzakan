# frozen_string_literal: true

RSpec.describe API::Actions::Config::Show do
  init_action_spec

  it "is successful" do
    response = action.call(params)
    expect(response).to be_successful
  end
end
