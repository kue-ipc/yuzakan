# frozen_string_literal: true

RSpec.describe API::Actions::Services::Update do
  init_action_spec

  let(:action_opts) { {service_repo: service_repo, adapter_repo: adapter_repo} }

  let(:action_params) { {id: id, **struct_to_hash(service)} }

  let(:id) { "service42" }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first)
      expect(json).to eq(struct_to_hash(service, case: :camel))
    end

    it "is ok with same name" do
      response = action.call({**params, name: id})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first)
      expect(json).to eq(struct_to_hash(service, case: :camel))
    end
  end

  shared_examples "failure" do
    it_behaves_like "bad id param"

    describe "with hoge id" do
      let(:id) { "hoge" }

      it_behaves_like "non-existent"
    end

    describe "with exsisted name" do
      let(:action_opts) {
        allow(service_repo).to receive(:exist?).with(service.name).and_return(true)
        {service_repo: service_repo, adapter_repo: adapter_repo}
      }

      it "is failure name duplication" do
        response = action.call(params)
        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({invalid: {name: ["重複しています。"]}})
      end
    end
  end

  shared_examples "update" do
    it_behaves_like "ok"
    it_behaves_like "failure"
  end

  it_behaves_like "unauthorized"

  context "when guest" do
    include_context "when guest"
    it_behaves_like "unauthorized"
  end

  context "when observer" do
    include_context "when observer"
    it_behaves_like "unauthorized"
  end

  context "when operator" do
    include_context "when operator"
    it_behaves_like "unauthorized"
  end

  context "when administrator" do
    include_context "when administrator"
    it_behaves_like "unauthorized"
  end

  context "when superuser" do
    include_context "when superuser"
    it_behaves_like "update"
  end
end
