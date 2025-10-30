# frozen_string_literal: true

RSpec.describe API::Actions::Groups::Show do
  init_action_spec
  let(:action_opts) {
    allow(group_repo).to receive(get).and_return(group)
    {attr_repo: group_repo}
  }
  let(:action_params) { {id: "gorup42"} }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq(group.to_h.except(:id))
    end
  end

  it_behaves_like "ok"

  describe "not existend" do
    let(:action_opts) {
      allow(group_repo).to receive(get).and_return(nil)
      {attr_repo: group_repo}
    }

    it_behaves_like "not found"
  end

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end
end
