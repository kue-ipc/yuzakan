# frozen_string_literal: true

RSpec.describe API::Actions::Groups::Index do
  init_action_spec
  let_pager

  # TODO: pagerを含めたrelaitonsを返す。
  let(:action_opts) {
    allow(group_repo).to receive(:index).and_return([[group], pager])
    {group_repo: group_repo, service_repo: service_repo}
  }

  # shares

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data].first).to eq(group.to_h.slice(:name, :label))
    end
  end

  shared_examples "index" do
    it_behaves_like "ok"
  end

  # test cases

  it_behaves_like "forbidden"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "forbidden"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "index"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "index"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "index"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "index"
  end
end
