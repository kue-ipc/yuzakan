# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Destroy do
  init_action_spec
  let(:action_opts) {
    allow(action_repo).to receive_messages(get: attr, unset: attr)
    {attr_repo: attr_repo}
  }
  let(:action_params) { {id: "attr42"} }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **attr.to_h.except(:id),
        mappings: mappings.map { |mapping| mapping.to_h.except(:id) },
      })
    end
  end

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  it_behaves_like "forbidden"

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
    it_behaves_like "forbidden"
  end

  context "when superuser" do
    include_context "when superuser"

    it_behaves_like "created"

    describe "not existend" do
      let(:action_opts) {
        allow(action_repo).to receive_messages(get: nil, unset: nil)
        {attr_repo: attr_repo}
      }

      it_behaves_like "not found"
    end
  end
end
