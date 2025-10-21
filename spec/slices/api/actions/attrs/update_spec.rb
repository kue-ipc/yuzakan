# frozen_string_literal: true

RSpec.describe API::Actions::Attrs::Update do
  init_action_spec

  let(:action_opts) {
    allow(attr_repo).to receive_messages(exist?: false, last_order: 9999, set: attr, renumber_order: 0)
    allow(service_repo).to receive_messages(all: [mapping.service])
    {
      attr_repo: attr_repo,
      service_repo: service_repo,
    }
  }

  let(:action_params) {
    {
      id: "attr42",
      **struct_to_hash(attr, except: [:mappings]),
      mappings: [struct_to_hash(mapping, except: [:attr])],
    }
  }

  shared_examples "ok" do
    it "is ok" do
      response = action.call(params)
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **struct_to_hash(attr, except: [:mappings]),
        mappings: attr.mappings.map { |mapping| struct_to_hash(mapping, except: [:attr]) },
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
    it_behaves_like "forbidden"
  end

  context "when superuser" do
    include_context "when superuser"

    it_behaves_like "ok"

    describe "not existend" do
      let(:action_opts) {
        allow(attr_repo).to receive_messages(get: nil, unset: nil)
        {attr_repo: attr_repo}
      }

      it_behaves_like "not found"
    end

    it "is ok with different name" do
      response = action.call({**params, name: "hoge", label: "ほげ"})
      expect(response).to be_successful
      expect(response.status).to eq 200
      expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
      json = JSON.parse(response.body.first, symbolize_names: true)
      expect(json[:data]).to eq({
        **attr.to_h.except(:id),
        name: "hoge",
        label: "ほげ",
        mappings: mappings.map { |mapping| mapping.to_h.except(:id) },
      })
    end

    describe "existed name" do
      let(:attr_repository) { instance_double(AttrRepository, **attr_repository_stubs, exist_by_name?: true) }

      it_behaves_like "not found"

      it "is failure with different name that exsits" do
        response = action.call({**params, name: "hoge"})
        expect(response).to be_client_error
        expect(response.status).to eq 422
        expect(response.headers["Content-Type"]).to eq "application/json; charset=utf-8"
        json = JSON.parse(response.body.first, symbolize_names: true)
        expect(json[:flash]).to eq({invalid: {name: ["重複しています。"]}})
      end
    end
  end
end
