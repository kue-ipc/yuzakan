# frozen_string_literal: true

RSpec.describe API::Actions::Services::Create do
  init_action_spec

  let(:action_opts) {
    allow(service_repo).to receive_messages(
      all: [service, another_service],
      get: nil, set: service, unset: nil, exist?: false,
      last_order: 42, renumber_order: 0)
    allow(service_repo).to receive(:transaction).and_yield

    allow(service_repo).to receive(:get).with("service42").and_return(service)
    # allow(service_repo).to receive(:set).with("service42", anything).and_return(service)
    allow(service_repo).to receive(:unset).with("service42").and_return(service)
    allow(service_repo).to receive(:exist?).with("service42").and_return(true)
    {service_repo: service_repo}
  }

  let(:action_params) { struct_to_hash(service) }

  # shares

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/services/#{service.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:location]).to eq "/api/services/#{service.name}"
      expect(json[:data]).to eq(struct_to_hash(service, case: :camel))
    end

    it "is ok without order param" do
      response = action.call(params.except(:order))
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/services/#{service.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:location]).to eq "/api/services/#{service.name}"
      expect(json[:data]).to eq(struct_to_hash(service, case: :camel))
    end

    it "is ok with minimum params" do
      response = action.call(params.except(:lable, :description, :order, :readable, :writable, :authenticatable,
        :password_changeable, :lockable, :group, :individual_password, :self_management))
      expect(response).to be_successful
      expect(response.status).to eq 201
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      expect(response.headers["Content-Location"]).to eq "/api/services/#{service.name}"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:location]).to eq "/api/services/#{service.name}"
      expect(json[:data]).to eq(struct_to_hash(service, case: :camel))
    end
  end

  shared_examples "failure params" do
    it "is failure without name" do
      response = action.call(params.except(:name))
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["存在しません。"]}})
    end

    it "is failure with bad name pattern" do
      response = action.call({**params, name: "!"})
      expect(response).to be_client_error
      expect(response.status).to eq 422
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:flash]).to eq({invalid: {name: ["形式が間違っています。"]}})
    end

    describe "with exist name" do
      it "is failure name duplication" do
        response = action.call({**params, name: "service42"})
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({invalid: {name: ["重複しています。"]}})
      end
    end
  end

  shared_examples "failure name duplication" do
  end

  shared_examples "create" do
    it_behaves_like "ok"
    it_behaves_like "failure params"
  end

  # test cases

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
    it_behaves_like "create"
  end
end
