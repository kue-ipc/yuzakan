# frozen_string_literal: true

RSpec.describe API::Actions::Affiliations::Update do
  init_action_spec

  let(:action_opts) {
    allow(attr_repo).to receive_messages(get: affiliation, set: affiliation)
    {affiliation_repo: affiliation_repo}
  }
  let(:action_params) {
    {
      id: "affiliation42",
      **affiliation.to_h.except(:id, :name, :created_at, :updated_at),
    }
  }

  shared_context "when not exist" do
    let(:action_opts) {
      allow(attr_repo).to receive_messages(get: nil)
      {affiliation_repo: affiliation_repo}
    }
  end

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        name: affiliation.name,
        label: affiliation.label,
        note: affiliation.note,
      })
    end
  end

  it_behaves_like "forbidden"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "forbidden"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "forbidden"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "ok"

    context "when not exist" do
      include_context "when not exist"
      it_behaves_like "not found"
    end
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "ok"

    context "when not exist" do
      include_context "when not exist"
      it_behaves_like "not found"
    end
  end
end
