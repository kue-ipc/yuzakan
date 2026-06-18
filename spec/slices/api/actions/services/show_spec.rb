# frozen_string_literal: true

RSpec.describe API::Actions::Services::Show do
  init_action_spec

  let(:action_opts) { {service_repo: service_repo} }

  let(:action_params) { {id: id} }

  let(:id) { "service42" }

  # shares

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq(struct_to_hash(service, case: :camel))
    end
  end

  shared_examples "ok restricted" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json).to eq(struct_to_hash(service, case: :camel).slice(:name, :label))
    end
  end

  shared_examples "failure" do
    it_behaves_like "bad id param"

    describe "with hoge id" do
      let(:id) { "hoge" }

      it_behaves_like "non-existent"
    end
  end

  shared_examples "show" do
    it_behaves_like "ok"
    it_behaves_like "failure"
  end

  shared_examples "show restricted" do
    it_behaves_like "ok restricted"
    it_behaves_like "failure"
  end

  # test cases

  it_behaves_like "show restricted"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "show restricted"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "show restricted"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "show"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "show"
  end
end
