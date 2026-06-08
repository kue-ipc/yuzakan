# frozen_string_literal: true

RSpec.describe API::Actions::Groups::Index do
  init_action_spec
  let_pager

  let(:action_opts) {
    allow(group_repo).to receive(:index).and_return([[group], pager])
    {group_repo: group_repo}
  }

  let(:index_params) {
    {
      page: 2, per_page: 50, order: "name.desc", search: "group", match: "extract",
      primary_only: true, hide_prohibited: true, show_deleted: true,
    }
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

    it "is ok with params" do
      response = action.call({**params, **index_params})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data].first).to eq(group.to_h.slice(:name, :label))
    end
  end

  shared_examples "ng" do
    it "is ng with bad params" do
      response = action.call({**params, **index_params, show_deleted: "bad"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:status]).to eq({code: 422, message: "Unprocessable Content"})
    end
  end

  shared_examples "index" do
    it_behaves_like "ok"
    it_behaves_like "ng"
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
