# frozen_string_literal: true

RSpec.describe API::Actions::Groups::Index do
  init_action_spec

  let(:action_opts) { {group_repo: group_repo, service_repo: service_repo} }

  # shares

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq(groups.map { |group| group.to_h.except(:id) })
    end
  end

  shared_examples "index" do
    it_behaves_like "ok"
  end

  # test cases

  it_behaves_like "index"

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
    it_behaves_like "index"
  end
end
