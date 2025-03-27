# frozen_string_literal: true

RSpec.describe Yuzakan::Actions::Locale::Index, :db do
  init_action_spec

  it "is successful" do
    response = subject.call(params)
    expect(response).to be_successful
  end
end
