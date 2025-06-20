# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Index do
  init_action_spec

  let(:action_opts) {
    allow(action_repo).to receive_messages(get: attr, unset: attr)
    {attr_repo: attr_repo}
  }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq(attrs.map { |attr| attr.to_h.except(:id) })
    end
  end

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  it_behaves_like "ok"
end
