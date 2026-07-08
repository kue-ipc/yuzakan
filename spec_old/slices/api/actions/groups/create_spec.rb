# frozen_string_literal: true

RSpec.describe API::Actions::Groups::Create do
  init_action_spec

  let(:action_opts) { {group_repo: group_repo} }

  let(:action_params) { struct_to_hash(group) }

  # TODO: その他のパターン

  # shares

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      # expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/groups/#{group.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:location]).to eq "/api/groups/#{group.name}"
      expect(json[:data]).to eq(data)
    end
  end

  shared_examples "create" do
    it_behaves_like "ok"
    # it_behaves_like "failure params"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "create"
  end
end
