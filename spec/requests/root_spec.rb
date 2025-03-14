# frozen_string_literal: true

RSpec.describe "Root", type: :request do
  it "is service unavalable" do
    get "/"

    expect(last_response.status).to be(503)
  end
end
