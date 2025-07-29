# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Index do
  init_action_spec

  let(:action_opts) {
    allow(affiliation_repo).to receive_messages(all: [affiliation])
    {affiliation_repo: affiliation_repo}
  }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq([{name: affiliation.name, label: affiliation.label}])
    end
  end

  it_behaves_like "ok"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "ok"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "ok"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok"
  end

  context "when superuser" do
    it_behaves_like "ok"
  end
end
